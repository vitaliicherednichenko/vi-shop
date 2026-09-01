class HideAdminSectionsForModerator
  # --- Product edit page ---

  Deface::Override.new(
    virtual_path: 'spree/admin/products/_form',
    name: 'hide_shipping_section_for_moderator',
    replace: "erb[loud]:contains('spree/admin/products/form/shipping')",
    text: <<-HTML
      <% if can?(:manage, Spree::ShippingCategory) %>
        <%= render 'spree/admin/products/form/shipping', f: f %>
      <% end %>
    HTML
  )

  Deface::Override.new(
    virtual_path: 'spree/admin/products/_form',
    name: 'hide_inventory_section_for_moderator',
    replace: "erb[loud]:contains('spree/admin/products/form/inventory')",
    text: <<-HTML
      <% if can?(:manage, Spree::StockLocation) %>
        <%= render 'spree/admin/products/form/inventory', f: f unless @product.has_variants? %>
      <% end %>
    HTML
  )

  # --- Sidebar (#main-sidebar) ---

  Deface::Override.new(
    virtual_path: 'spree/admin/shared/sidebar/_store_nav',
    name: 'hide_policies_for_moderator',
    surround: "erb[loud]:contains('policies')",
    text: "<% unless restricted_moderator? %><%= render_original %><% end %>"
  )

  Deface::Override.new(
    virtual_path: 'spree/admin/shared/sidebar/_store_nav',
    name: 'hide_checkout_for_moderator',
    surround: "erb[loud]:contains('checkout')",
    text: "<% unless restricted_moderator? %><%= render_original %><% end %>"
  )

  Deface::Override.new(
    virtual_path: 'spree/admin/shared/sidebar/_store_nav',
    name: 'hide_audit_log_for_moderator',
    replace: "erb[silent]:contains('can?(:manage, Spree::Store)')",
    text: "<% if can?(:manage, Spree::Store) && !restricted_moderator? %>"
  )

  Deface::Override.new(
    virtual_path: 'spree/admin/shared/sidebar/_vendors_nav',
    name: 'hide_vendors_for_moderator',
    surround: "li",
    text: "<% unless restricted_moderator? %><%= render_original %><% end %>"
  )
end
