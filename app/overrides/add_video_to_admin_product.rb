class AddVideoToAdminProduct
  Deface::Override.new(
    virtual_path: 'spree/admin/shared/_seo',
    name: 'add_video_to_admin_product',
    insert_after: "div.seo-form",
    text: <<-HTML
      <% if f.object.respond_to?(:video_url) %>
      <div class="card">
        <div class="card-header">
          <h5 class="card-title"><%= Spree.t('admin.products.video.title') %></h5>
        </div>
        <div class="card-body">
          <div class="form-group">
            <%= f.label :video_url, Spree.t('admin.products.video.video_url') %>
            <%= f.text_field :video_url, placeholder: 'https://youtu.be/... or https://vimeo.com/...', class: 'form-control' %>
            <small class="form-text text-muted d-block mt-2">
              <%= Spree.t('admin.products.video.url_help') %>
            </small>

            <% if f.object.video_url.present? %>
              <div class="mt-3">
                <h6><%= Spree.t('admin.products.video.preview') %></h6>
                <div style="max-width: 400px;">
                  <%= render 'spree/products/video', product: f.object %>
                </div>
              </div>
            <% end %>
          </div>
        </div>
      </div>
      <% end %>

      <% if f.object.respond_to?(:image_urls) %>
      <div class="card mb-4">
        <div class="card-header">
          <h5 class="card-title"><%= Spree.t(:image_urls, default: 'Image URLs') %></h5>
        </div>
        <div class="card-body">
          <div class="form-group">
            <%= f.label :image_urls, Spree.t(:image_urls, default: 'Image URLs') %>
            <%= f.text_area :image_urls, rows: 4, placeholder: 'https://example.com/image.jpg', class: 'form-control' %>
            <small class="form-text text-muted d-block mt-2">
              <%= Spree.t(:product_image_urls_hint, default: 'One image URL per line. Used as the product images when none are uploaded.') %>
            </small>

            <% if f.object.respond_to?(:public_image_urls) && f.object.public_image_urls.any? %>
              <div class="mt-3 d-flex flex-wrap" style="gap: 0.5rem;">
                <% f.object.public_image_urls.each do |image_url| %>
                  <img src="<%= image_url %>" alt="" loading="lazy" style="height: 80px; width: 80px; object-fit: cover; border-radius: 4px;" />
                <% end %>
              </div>
            <% end %>
          </div>
        </div>
      </div>
      <% end %>

      <% if f.object.respond_to?(:card_size) %>
      <div class="card mb-4">
        <div class="card-header">
          <h5 class="card-title"><%= Spree.t(:product_card_size, default: 'Card size') %></h5>
        </div>
        <div class="card-body">
          <div class="form-group">
            <%= f.label :card_size, Spree.t(:product_card_size, default: 'Card size') %>
            <%= f.select :card_size,
                  options_for_select(
                    [
                      [Spree.t(:product_card_size_normal, default: 'Normal'), 'normal'],
                      [Spree.t(:product_card_size_wide, default: 'Wide (2 columns)'), 'wide'],
                      [Spree.t(:product_card_size_large, default: 'Large (full width on mobile)'), 'large']
                    ],
                    f.object.card_size
                  ),
                  {}, class: 'custom-select' %>
            <small class="form-text text-muted d-block mt-2">
              <%= Spree.t(:product_card_size_hint, default: 'How big this product appears in storefront product listings.') %>
            </small>
          </div>
        </div>
      </div>
      <% end %>
    HTML
  )
end
