module Spree
  module PermissionSets
    class Moderator < Base
      def activate!
        return if user.spree_admin?(store)

        can :manage, :all
        cannot [:edit, :update], Spree::RefundReason, mutable: false
        cannot [:edit, :update], Spree::ReimbursementType, mutable: false
        cannot [:update, :destroy], Spree::Role, name: ['admin']

        cannot :manage, Spree::Order
        cannot :manage, Spree::ShippingCategory
        cannot :manage, Spree::StockLocation
        cannot :manage, Spree::StockItem

        cannot :manage, Spree::Promotion
        cannot :manage, Spree::Report
        cannot :manage, Spree::PaymentMethod
        cannot :manage, Spree::Zone
        cannot :manage, Spree::ShippingMethod
        cannot :manage, Spree::TaxRate
        cannot :manage, Spree::CustomerReturn
        cannot :manage, Spree::ReturnAuthorization
        cannot :manage, Spree::ReturnAuthorizationReason
      end
    end
  end
end
