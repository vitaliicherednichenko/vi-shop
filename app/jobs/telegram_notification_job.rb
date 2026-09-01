class TelegramNotificationJob < ApplicationJob
  queue_as :default

  def perform(text, chat_id: ENV["TELEGRAM_CHAT_ID"], parse_mode: nil)
    TelegramNotifier.send_message(text, chat_id: chat_id, parse_mode: parse_mode)
  end
end
