module Spree
  module PageSections
    module NewsletterDecorator
      def self.prepended(base)
        base.preference :image_url, :string
      end
    end
  end
end

Spree::PageSections::Newsletter.prepend(Spree::PageSections::NewsletterDecorator)
