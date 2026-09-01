module Spree
  module PageBlocks
    class YoutubeShort < Spree::PageBlock
      preference :video_url, :string
      preference :title, :string

      def icon_name
        'brand-youtube'
      end
    end
  end
end
