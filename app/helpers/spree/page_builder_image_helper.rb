module Spree
  module PageBuilderImageHelper
   def page_block_image_tag(block, width:, **options)
      if block.preferred_image_url.present?
        image_tag(block.preferred_image_url, **options)
      elsif block.asset.attached?
        image_tag(spree_image_url(block.asset, width: width, height: nil), **options)
      end
    end
  end
end
