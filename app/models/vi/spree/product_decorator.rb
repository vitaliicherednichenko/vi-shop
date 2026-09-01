module Vi
  module Spree
    module ProductDecorator
      def self.prepended(base)
        base.before_validation :generate_sku, on: :create
        base.before_validation :set_default_price, on: :create
        base.after_create :set_default_shop_stock
        base.after_create_commit :notify_new_product_on_telegram
      end

      def set_default_price
        self.price = 1 if price.blank?
      end

      def notify_new_product_on_telegram
        TelegramNotificationJob.perform_later("🆕 Нове оголошення: #{name}")
      end

      def set_default_shop_stock
        location = ::Spree::StockLocation.find_by(default: true) || ::Spree::StockLocation.first
        return unless location

        stock_item = location.stock_item_or_create(master)
        stock_item.set_count_on_hand(1) if stock_item.count_on_hand.to_i.zero?
      end

      def generate_sku
        return if sku.present?

        prefix = name.to_s.parameterize(separator: '').upcase[0, 8].presence || 'SKU'

        self.sku = Enumerator
                   .produce { "#{prefix}-#{SecureRandom.alphanumeric(5).upcase}" }
                   .find { |candidate| ::Spree::Variant.where(sku: candidate).none? }
      end

      # Controls how big the product card is in storefront listings.
      CARD_SIZES = %w[normal wide large].freeze

      def card_size
        size = public_metadata&.dig('card_size').to_s
        CARD_SIZES.include?(size) ? size : 'normal'
      end

      def card_size=(value)
        self.public_metadata = (public_metadata || {}).merge('card_size' => value.to_s)
      end

      def video_url
        public_metadata&.dig('video_url')
      end

      def video_url=(url)
        self.public_metadata = (public_metadata || {}).merge('video_url' => url.presence)
      end

      def public_image_urls
        raw = public_metadata && (public_metadata[:image_urls] || public_metadata[:image_url])
        Array(raw).map { |u| u.to_s.strip }.reject(&:blank?)
      end

      def public_image_url
        public_image_urls.first
      end

      def image_urls
        public_image_urls.join("\n")
      end

      def image_urls=(value)
        urls = value.is_a?(Array) ? value : value.to_s.split(/[\r\n,]+/)
        urls = urls.map(&:strip).reject(&:blank?)
        self.public_metadata = (public_metadata || {}).merge('image_urls' => urls)
      end
    end
  end
end
Spree::Product.prepend Vi::Spree::ProductDecorator if Spree::Product.included_modules.exclude?(Vi::Spree::ProductDecorator)
