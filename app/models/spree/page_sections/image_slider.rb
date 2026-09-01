module Spree
  module PageSections
    class ImageSlider < Spree::PageSection
      TOP_PADDING_DEFAULT = 20
      BOTTOM_PADDING_DEFAULT = 20
      TOP_BORDER_WIDTH_DEFAULT = 0

      preference :overlay_transparency, :integer, default: 40
      preference :heading, :string, default: Spree.t('page_sections.image_slider.heading_default')
      preference :heading_size, :string, default: 'large'
      preference :height, :integer, default: 384
      preference :heading_alignment, :string, default: 'left'
      preference :title_font_size, :string, default: 'large'
      preference :text_font_size, :string, default: 'medium'

      def default_blocks
        [
          Spree::PageBlocks::ImageGridBlock.new(
            preferred_title: Spree.t('page_sections.image_slider.title_default')
          ),
          Spree::PageBlocks::ImageGridBlock.new(
            preferred_title: Spree.t('page_sections.image_slider.title_default')
          ),
          Spree::PageBlocks::ImageGridBlock.new(
            preferred_title: Spree.t('page_sections.image_slider.title_default')
          )
        ]
      end

      def available_blocks_to_add
        [
          Spree::PageBlocks::ImageGridBlock
        ]
      end

      def blocks_available?
        true
      end

      def can_sort_blocks?
        true
      end

      def icon_name
        'slideshow'
      end
    end
  end
end
