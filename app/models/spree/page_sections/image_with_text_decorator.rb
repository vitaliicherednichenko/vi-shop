module Spree
  module PageSections
    module ImageWithTextDecorator
      def self.prepended(base)
        base.preference :image_url, :string
      end
    end
  end
end

Spree::PageSections::ImageWithText.prepend(Spree::PageSections::ImageWithTextDecorator)
