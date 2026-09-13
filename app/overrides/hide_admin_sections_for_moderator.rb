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

end
