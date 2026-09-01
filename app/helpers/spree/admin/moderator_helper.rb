module Spree
  module Admin
    module ModeratorHelper
      def restricted_moderator?
        user = try_spree_current_user
        return false unless user.respond_to?(:has_spree_role?)

        user.has_spree_role?('moderator') && !user.spree_admin?
      end
    end
  end
end
