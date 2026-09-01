module Spree
  module ProductCardHelper
    # Grid-span classes for a product card based on its card_size public_metadata.
    # The listing grid is grid-cols-2 lg:grid-cols-4, so:
    #   normal -> 1 column (default)
    #   wide   -> 2 columns on desktop
    #   large  -> 2 columns on mobile and desktop (full width on mobile)
    # Classes are kept literal so Tailwind (which scans app/helpers/**/*.rb) keeps them.
    def product_card_size_classes(product)
      size = product.respond_to?(:card_size) ? product.card_size : 'normal'

      case size
      when 'wide'  then 'lg:col-span-2'
      when 'large' then 'col-span-2 lg:col-span-2'
      else ''
      end
    end
  end
end
