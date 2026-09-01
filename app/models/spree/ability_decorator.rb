module Spree
  class AbilityDecorator
    include CanCan::Ability

    def initialize(user)
      return if user.blank? || !user.respond_to?(:has_spree_role?)
      return unless user.has_spree_role?('moderator') && !user.spree_admin?

      can :manage, :all
      cannot [:edit, :update], Spree::RefundReason, mutable: false
      cannot [:edit, :update], Spree::ReimbursementType, mutable: false

      cannot :manage, Spree::Order
      cannot :manage, Spree::ShippingCategory
      cannot :manage, Spree::StockLocation
      cannot :manage, Spree::StockItem

      cannot :manage, Spree::Promotion
      cannot :manage, Spree::Report
      cannot :manage, Spree::CustomDomain
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

Spree::Ability.register_ability(Spree::AbilityDecorator)
