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
spree_opts = '~> 5.1'
gem "spree", spree_opts
gem "spree_emails", spree_opts
gem "spree_sample", spree_opts
gem "spree_admin", spree_opts
gem "spree_storefront", spree_opts
gem "spree_i18n"
gem "spree_stripe", '~> 1.2'
gem "spree_google_analytics", "~> 1.0"
gem "spree_klaviyo", "~> 1.0"
gem "spree_paypal_checkout", "~> 0.5"

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
