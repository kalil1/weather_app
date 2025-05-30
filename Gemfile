source "https://rubygems.org"

ruby '2.7.6' # Rails 6 compatible

gem 'rails', '~> 6.1.7'
gem 'pg'
gem 'puma'
gem 'rack-cors'
gem 'httparty' # For external API requests
gem 'dotenv-rails' # For API keys and config
gem 'redis' # For caching
gem 'bootsnap', require: false
gem 'rspec-rails', group: [:development, :test]
gem 'logger', '1.4.2'

gem "sprockets-rails"
gem "importmap-rails"

gem "turbo-rails"

gem "stimulus-rails"
gem "jbuilder"
gem "tzinfo-data", platforms: %i[ mswin mingw x64_mingw jruby ]

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mswin mingw x64_mingw ]
end

group :development do
  gem "web-console"
  # gem "rack-mini-profiler"
  # gem "spring"
end

group :test do
  gem "capybara"
  gem 'rails-controller-testing'
  gem "selenium-webdriver"
end
