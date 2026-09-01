module Spree
  module PageSections
    class YoutubeShortsSlider < Spree::PageSection
      TOP_PADDING_DEFAULT = 20
      BOTTOM_PADDING_DEFAULT = 20
      TOP_BORDER_WIDTH_DEFAULT = 0

      preference :heading, :string, default: Spree.t('page_sections.youtube_shorts_slider.heading_default')
      preference :heading_size, :string, default: 'large'
      preference :heading_alignment, :string, default: 'left'

      def default_blocks
        [
          Spree::PageBlocks::YoutubeShort.new(preferred_video_url: 'https://www.youtube.com/shorts/'),
          Spree::PageBlocks::YoutubeShort.new(preferred_video_url: 'https://www.youtube.com/shorts/'),
          Spree::PageBlocks::YoutubeShort.new(preferred_video_url: 'https://www.youtube.com/shorts/')
        ]
      end

      def available_blocks_to_add
        [
          Spree::PageBlocks::YoutubeShort
        ]
      end

      def blocks_available?
        true
      end

      def can_sort_blocks?
        true
      end

      def icon_name
        'brand-youtube'
      end
    end
  end
end
