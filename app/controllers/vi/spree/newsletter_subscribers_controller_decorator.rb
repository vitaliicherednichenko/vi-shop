module Vi
  module Spree
    module NewsletterSubscribersControllerDecorator
      def create
        super
        notify_newsletter_subscription_on_telegram
      end

      private

      def notify_newsletter_subscription_on_telegram
        return if flash[:success].blank?

        email = newsletter_params[:email]
        return if email.blank?

        TelegramNotificationJob.perform_later("📧 Нова підписка на розсилку: #{email}")
      rescue StandardError => e
        Rails.logger.error("[Telegram] newsletter notify failed: #{e.class}: #{e.message}")
      end
    end
  end
end
::Spree::NewsletterSubscribersController.prepend Vi::Spree::NewsletterSubscribersControllerDecorator if ::Spree::NewsletterSubscribersController.included_modules.exclude?(Vi::Spree::NewsletterSubscribersControllerDecorator)
