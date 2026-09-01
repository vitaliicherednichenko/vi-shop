# frozen_string_literal: true

# Runs a Google Sheet product import in the background and reports the outcome to Telegram.
class ProductImportJob < ApplicationJob
  queue_as :default

  def perform(sheet_url, store_id: nil)
    store = store_id ? Spree::Store.find_by(id: store_id) : Spree::Store.default
    result = GoogleSheetProductImporter.new(sheet_url, store: store).call

    notify(Spree.t('admin.product_import.telegram.finished', summary: result.summary), result)
  rescue GoogleSheetProductImporter::InvalidUrlError => e
    notify(Spree.t('admin.product_import.telegram.invalid', message: e.message))
  rescue => e
    Rails.logger.error("[ProductImportJob] #{e.class}: #{e.message}")
    notify(Spree.t('admin.product_import.telegram.failed', message: e.message))
  end

  private

  def notify(text, result = nil)
    full = text.dup
    if result && result.errors.any?
      full << "\n\n" << Spree.t('admin.product_import.telegram.errors_heading') << "\n" << result.errors.first(10).join("\n")
    end
    TelegramNotificationJob.perform_later(full)
  end
end
