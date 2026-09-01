module Spree
  module PageBlocks
    class ImageGridBlock < Spree::PageBlock
      alias image asset

      preference :image_url, :string
      preference :height, :integer, default: 640
      preference :mobile_height, :integer, default: 320
      preference :title, :string, default: Spree.t('page_sections.image_grid.title_default')
      preference :text, :string, default: Spree.t('page_sections.image_grid.text_default')
      preference :title_font_size, :string, default: 'large'
      preference :text_font_size, :string, default: 'medium'

      preference :text_align, :string, default: 'center'
      preference :vertical_align, :string, default: 'center'

      has_one :link, lambda(&:links), class_name: 'Spree::PageLink', as: :parent, dependent: :destroy, inverse_of: :parent
      accepts_nested_attributes_for :link

      def allowed_linkable_types
        ['Spree::Product', 'Spree::Taxon', 'Spree::Page', 'Spree::ExternalLink']
      end

      def default_links
        @default_links.presence || [
          Spree::PageLink.new(
            label: Spree.t(:shop_all),
            linkable: theme.pages.find_by(type: 'Spree::Pages::ShopAll')
          )
        ]
      end

      def icon_name
        'photo'
      end
    end
  end
end
