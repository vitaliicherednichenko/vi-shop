module Vi
  module Spree
    module ProductsHelperDecorator
      HIDDEN_SORT_OPTIONS = %w[best-selling price-low-to-high price-high-to-low].freeze

      def taxons_sort_options
        super.reject { |option| HIDDEN_SORT_OPTIONS.include?(option[:value]) }
      end
    end
  end
end
Spree::ProductsHelper.prepend Vi::Spree::ProductsHelperDecorator if Spree::ProductsHelper.included_modules.exclude?(Vi::Spree::ProductsHelperDecorator)
