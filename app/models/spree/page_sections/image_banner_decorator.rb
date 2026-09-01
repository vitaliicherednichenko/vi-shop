module Spree
  module PageSections
    module ImageBannerDecorator
      def self.prepended(base)
        base.preference :image_url, :string
      end
    end
  end
end

Spree::PageSections::ImageBanner.prepend(Spree::PageSections::ImageBannerDecorator)
