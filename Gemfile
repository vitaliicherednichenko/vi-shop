source "https://rubygems.org"

ruby '3.3.0'

gem 'rails', '~> 8.0.0'
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem 'mini_racer', platforms: :ruby
gem "redis", ">= 4.0.1"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false
gem "image_processing", "~> 1.13"
gem 'sidekiq'
gem "devise"
gem 'sentry-ruby'
gem 'sentry-rails'
gem 'sentry-sidekiq'
gem 'deface'

gem 'aws-sdk-s3', require: false

# Spree gems
spree_opts = '~> 5.4.0'
gem "spree", spree_opts
gem "spree_emails", spree_opts
gem "spree_admin", spree_opts
gem "spree_storefront", spree_opts
gem "spree_legacy_product_properties", "~> 1.0"
gem "spree_i18n"
gem "spree_stripe", '~> 1.6'
gem "spree_google_analytics", "~> 1.0"
gem "spree_klaviyo", "~> 1.0"
gem "spree_paypal_checkout", "~> 0.7"

gem "sprockets-rails"
gem "tailwindcss-rails", "~> 4.0"
gem "tailwindcss-ruby", "~> 4.0"
gem "connection_pool", "~> 2.5"
gem "sass-embedded", "~> 1.89.2"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ]
  gem 'brakeman'
  gem 'dotenv-rails', '~> 3.1'
  gem 'rubocop', '~> 1.23'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'selenium-webdriver', '~> 4.10.0'
  gem 'pry'
  gem 'pry-remote'
end

group :development do
  gem 'listen', '>= 3.0'
  gem "foreman"
  gem "web-console"
  gem "letter_opener"
  gem 'solargraph'
  gem 'solargraph-rails'
  gem 'ruby-lsp'
  gem 'ruby-lsp-rails'
end

group :test do
  gem 'capybara', '~> 3.39'
  gem 'capybara-screenshot', '~> 1.0'
  gem 'email_spec'
  gem 'ffaker', '~> 2.9' # used by Spree factories; was a transitive dep of spree_sample (removed in 5.4)
  gem 'factory_bot'
  gem 'factory_bot_rails'
  gem 'database_cleaner'
  gem 'rspec-activemodel-mocks', '~> 1.0'
  gem 'rspec-rails', '~> 8.0'
  gem 'rspec-retry'
  gem 'rspec_junit_formatter'
  gem 'rubocop-rspec'
  gem 'jsonapi-rspec'
  gem 'simplecov'
  gem 'webmock', '~> 3.7', require: false
  gem 'timecop'
  gem 'rails-controller-testing'
  gem 'webdrivers', '~> 5.0'
end
