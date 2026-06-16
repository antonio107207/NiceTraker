source "https://rubygems.org"

gem "rails", "~> 8.1.3"
gem "propshaft"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "jbuilder"

# Auth
gem "devise"
gem "omniauth-google-oauth2"
gem "omniauth-github"
gem "omniauth-gitlab"
gem "omniauth-rails_csrf_protection"
gem "bcrypt", "~> 3.1.7"

# Authorization
gem "pundit"

# Ordering (lists, cards)
gem "acts_as_list"

# Notifications
gem "noticed", "~> 3.0"

# Search
gem "pg_search"

# Rich text attachments
gem "image_processing", "~> 1.2"

# Rails 8 built-in backends
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

gem "csv"

gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false
gem "tzinfo-data", platforms: %i[ windows jruby ]

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "factory_bot_rails"
  gem "faker"
  gem "rspec-rails"
end

group :development do
  gem "web-console"
  gem "letter_opener"
end
