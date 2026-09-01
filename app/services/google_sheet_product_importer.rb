# frozen_string_literal: true

require "csv"
require "faraday"
require "faraday/follow_redirects"

class GoogleSheetProductImporter
  Result = Struct.new(:created, :updated, :skipped, :errors, keyword_init: true) do
    def total = created + updated + skipped
    def summary
      Spree.t(
        'admin.product_import.summary',
        created: created, updated: updated, skipped: skipped, errors: errors.size
      )
    end
  end

  class InvalidUrlError < StandardError; end

  PROPERTY_HEADER = /\Aproperty\s*[:\-_]\s*(.+)\z/i
  DEFAULT_TAXONOMY = "Categories"
  TAXON_KEYS = %i[taxons taxonomies category].freeze
  IMAGE_KEYS = %i[image_urls image_url].freeze

  def initialize(sheet_url, store: nil)
    @sheet_url = sheet_url.to_s.strip
    @store = store || Spree::Store.default
  end

  def self.call(...) = new(...).call

  def call
    result = Result.new(created: 0, updated: 0, skipped: 0, errors: [])
    csv = CSV.parse(fetch_csv, headers: true)

    csv.each_with_index do |row, index|
      attrs = normalize_row(row)
      name = attrs[:name].to_s.strip

      if name.blank?
        result.skipped += 1
        next
      end

      begin
        upsert_product(attrs, row, name, result)
      rescue => e
        result.errors << Spree.t('admin.product_import.row_error', row: index + 2, name: name, message: e.message)
      end
    end

    result
  end

  def csv_export_url
    id = @sheet_url[%r{/spreadsheets/d/([A-Za-z0-9_-]+)}, 1]
    raise InvalidUrlError, Spree.t('admin.product_import.errors.invalid_url') if id.blank?

    gid = @sheet_url[/[#&?]gid=(\d+)/, 1]
    url = "https://docs.google.com/spreadsheets/d/#{id}/export?format=csv"
    url += "&gid=#{gid}" if gid.present?
    url
  end

  private

  def fetch_csv
    response = connection.get(csv_export_url)
    unless response.success?
      raise InvalidUrlError, Spree.t('admin.product_import.errors.download_failed', status: response.status)
    end

    body = response.body.to_s
    if body.lstrip.start_with?("<")
      raise InvalidUrlError, Spree.t('admin.product_import.errors.not_public')
    end

    body.force_encoding("UTF-8")
  end

  def connection
    @connection ||= Faraday.new do |f|
      f.response :follow_redirects
      f.adapter Faraday.default_adapter
    end
  end

  def normalize_row(row)
    row.to_h.transform_keys { |k| k.to_s.strip.downcase.tr(" ", "_").to_sym }
  end

  def upsert_product(attrs, row, name, result)
    product = find_existing(attrs, name)
    new_record = product.nil?
    product ||= Spree::Product.new(name: name)

    apply_attributes(product, attrs)
    attributes_changed = product.changed? || master_changed?(product)
    product.save!

    store_changed = false
    unless product.stores.include?(@store)
      @store.products << product
      store_changed = true
    end

    properties_changed = apply_properties(product, row, attrs)
    taxons_changed = apply_taxons(product, attrs)
    image_changed = sync_image(product, attrs)

    if new_record
      result.created += 1
    elsif attributes_changed || store_changed || properties_changed || taxons_changed || image_changed
      result.updated += 1
    end
  end

  def master_changed?(product)
    master = product.master
    return false if master.nil?

    master.new_record? || master.changed? ||
      (master.default_price && (master.default_price.new_record? || master.default_price.changed?))
  end

  def find_existing(attrs, name)
    sku = attrs[:sku].to_s.strip
    if sku.present?
      variant = Spree::Variant.find_by(sku: sku)
      return variant.product if variant
    end
    Spree::Product.find_by(name: name)
  end

  def apply_attributes(product, attrs)
    product.name = attrs[:name].to_s.strip if attrs[:name].present?
    product.description = attrs[:description] if attrs.key?(:description)
    product.sku = attrs[:sku].to_s.strip if attrs[:sku].present?
    product.price = parse_price(attrs[:price]) if attrs[:price].present?

    if product.respond_to?(:image_urls=) && (image_key = IMAGE_KEYS.find { |k| attrs.key?(k) })
      product.image_urls = attrs[:image_urls].presence || attrs[image_key]
    end
    if product.respond_to?(:video_url=) && attrs.key?(:video_url)
      product.video_url = attrs[:video_url].to_s.strip.presence
    end

    if attrs[:card_size].present? && product.respond_to?(:card_size=)
      product.card_size = attrs[:card_size].to_s.strip.downcase
    end
  end

  def parse_price(value)
    value.to_s.gsub(/[^\d.,]/, "").tr(",", ".").to_f
  end

  def apply_properties(product, row, attrs)
    changed = false

    row.headers.each do |header|
      match = header.to_s.strip.match(PROPERTY_HEADER)
      next unless match

      name = match[1].strip
      value = row[header].to_s.strip

      changed = true if value.blank? ? remove_property(product, name) : set_property(product, name, value)
    end

    attrs[:properties].to_s.split(/[;\n]+/).each do |pair|
      key, value = pair.split(":", 2).map { |part| part.to_s.strip }
      changed = true if key.present? && value.present? && set_property(product, key, value)
    end

    changed
  end

  def set_property(product, presentation, value)
    return false if product.property(presentation.parameterize) == value

    product.set_property(presentation, value, presentation)
    true
  end

  def remove_property(product, presentation)
    product_property = product.product_properties
                              .joins(:property)
                              .find_by(spree_properties: { name: presentation.parameterize })
    return false if product_property.nil?

    product_property.destroy
    true
  end

  def apply_taxons(product, attrs)
    present_keys = TAXON_KEYS.select { |key| attrs.key?(key) }
    return false if present_keys.empty?

    desired = present_keys.filter_map { |key| attrs[key] }.join(";")
                          .split(/[;\n]+/).map(&:strip).reject(&:blank?)
                          .filter_map { |path| find_or_create_taxon_path(path) }
                          .uniq

    sync_taxons(product, desired)
  end

  def sync_taxons(product, desired)
    current = product.taxons.to_a
    changed = false

    (desired - current).each do |taxon|
      product.taxons << taxon
      changed = true
    end

    (current - desired).each do |taxon|
      product.taxons.delete(taxon)
      changed = true
    end

    changed
  end

  def find_or_create_taxon_path(path)
    segments = path.split(/>|→|\//).map(&:strip).reject(&:blank?)
    return if segments.empty?

    taxonomy_name = segments.size > 1 ? segments.shift : DEFAULT_TAXONOMY
    taxonomy = Spree::Taxonomy.find_or_create_by!(name: taxonomy_name, store: @store)

    parent = taxonomy.root
    segments.each do |segment|
      parent = taxonomy.taxons.find_or_create_by!(name: segment, parent_id: parent.id)
    end
    parent
  end

  def sync_image(product, attrs)
    return false unless IMAGE_KEYS.any? { |key| attrs.key?(key) }

    url = product.respond_to?(:public_image_url) ? product.public_image_url : attrs[:image_url]

    if url.blank?
      return false if product.master.images.empty?

      product.master.images.destroy_all
      return true
    end

    return false if product.master.images.any?

    response = connection.get(url)
    return false unless response.success?

    filename = File.basename(URI.parse(url).path).presence || "image.jpg"
    image = product.master.images.new
    image.attachment.attach(io: StringIO.new(response.body), filename: filename)
    image.save
    true
  rescue => e
    Rails.logger.warn("[GoogleSheetProductImporter] image sync failed for #{product.name}: #{e.message}")
    false
  end
end
