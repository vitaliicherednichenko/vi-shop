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
