module Vi
  module Spree
    module Admin
      module ProductsHelperDecorator
        def sorted_product_properties(product)
          product.product_properties.to_a.sort_by { |product_property| product_property.property&.position.to_i }
        end
      end
    end
  end
end
::Spree::Admin::ProductsHelper.prepend Vi::Spree::Admin::ProductsHelperDecorator if ::Spree::Admin::ProductsHelper.included_modules.exclude?(Vi::Spree::Admin::ProductsHelperDecorator)
