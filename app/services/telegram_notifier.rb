class TelegramNotifier
  TELEGRAM_API_URL = "https://api.telegram.org".freeze

  class << self
    def send_message(text, chat_id: ENV["TELEGRAM_CHAT_ID"], parse_mode: nil)
      token = ENV["TELEGRAM_BOT_TOKEN"]

      if token.blank? || chat_id.blank?
        Rails.logger.warn("[TelegramNotifier] TELEGRAM_BOT_TOKEN or TELEGRAM_CHAT_ID not set; skipping message")
        return false
      end

      body = { chat_id: chat_id, text: text, disable_web_page_preview: true }
      body[:parse_mode] = parse_mode if parse_mode.present?

      response = Faraday.post(
        "#{TELEGRAM_API_URL}/bot#{token}/sendMessage",
        body.to_json,
        "Content-Type" => "application/json"
      )

      unless response.success?
        Rails.logger.error("[TelegramNotifier] Telegram API error #{response.status}: #{response.body}")
      end

      response.success?
    rescue Faraday::Error => e
      Rails.logger.error("[TelegramNotifier] request failed: #{e.class}: #{e.message}")
      false
    end
  end
end
