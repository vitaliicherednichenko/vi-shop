Rails.application.config.to_prepare do
  %i[video_url image_urls card_size].each do |attr|
    unless Spree::PermittedAttributes.product_attributes.include?(attr)
      Spree::PermittedAttributes.product_attributes << attr
    end
  end
end
