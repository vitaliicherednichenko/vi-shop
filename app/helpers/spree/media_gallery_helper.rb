 require 'digest'

module Spree
  module MediaGalleryHelper
    def gallery_image_url?(image)
      image.is_a?(String)
    end

    def gallery_image_dom_id(image)
      gallery_image_url?(image) ? Digest::MD5.hexdigest(image)[0, 10] : image.id
    end

    def gallery_image_zoom_src(image, width:, height:)
      gallery_image_url?(image) ? image : spree_image_url(image, width: width, height: height)
    end

    def gallery_image_alt(image, product = nil)
      gallery_image_url?(image) ? product&.name : image_alt(image)
    end

    def gallery_image_tag(image, width:, height:, **options)
      if gallery_image_url?(image)
        image_tag(image, **options)
      else
        spree_image_tag(image, width: width, height: height, **options)
      end
    end

    def vi_product_gallery_images(product, selected_variant:, variant_from_options:)
      variant = selected_variant || variant_from_options
      if variant && !variant.is_master? && variant.respond_to?(:gallery_media)
        variant_media = gallery_image_assets(variant.gallery_media)
        return variant_media if variant_media.any?
      end

      product_media = product.respond_to?(:gallery_media) ? gallery_image_assets(product.gallery_media) : []
      return product_media if product_media.any?

      product_media_gallery_images(product, selected_variant: selected_variant, variant_from_options: variant_from_options)
    end

    def gallery_image_assets(assets)
      assets.to_a.select { |asset| asset.try(:media_type).in?([nil, 'image']) && asset.attachment.attached? }
    end

    def video_thumbnail_url(url)
      return nil if url.blank?

      if url.include?('youtu.be')
        id = url.split('youtu.be/').last.to_s.split('?').first
      elsif url.include?('youtube.com')
        id = url.split('v=').last.to_s.split('&').first
      end

      "https://img.youtube.com/vi/#{id}/hqdefault.jpg" if id.present?
    end
  end
end
