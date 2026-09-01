module Spree
  module PageBlocks
    class ImageCollectionSlider < Spree::PageBlock
      alias image asset

      TOP_PADDING_DEFAULT = 20
      BOTTOM_PADDING_DEFAULT = 20

      preference :image_url, :string
      preference :height, :integer, default: 580
      preference :mobile_height, :integer, default: 540
      preference :title, :string, default: Spree.t('page_sections.image_collection_slider.title_default')
      preference :text, :string, default: Spree.t('page_sections.image_collection_slider.text_default')
      preference :title_font_size, :string, default: 'small'
      preference :text_font_size, :string, default: 'large'

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
