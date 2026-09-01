module Spree
  module YoutubeShortsHelper
    def youtube_video_id(url)
      return nil if url.blank?

      url = url.to_s.strip

      if (match = url.match(%r{(?:shorts/|youtu\.be/|embed/|[?&]v=)([A-Za-z0-9_-]{6,})}))
        return match[1]
      end

      url if url =~ /\A[A-Za-z0-9_-]{6,}\z/    end

    def youtube_embed_url(url)
      id = youtube_video_id(url)
      return nil if id.blank?

      "https://www.youtube.com/embed/#{id}?rel=0&playsinline=1"
    end

    def youtube_short_thumbnail_url(url)
      id = youtube_video_id(url)
      "https://img.youtube.com/vi/#{id}/hqdefault.jpg" if id.present?
    end
  end
end
