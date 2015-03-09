ruby '2.2.0'

source 'https://rubygems.org' do
  gem 'rails', '4.2.0'
  gem 'sqlite3'
  gem 'sass-rails', '~> 5.0'
  gem 'uglifier', '>= 1.3.0'
  gem 'coffee-rails', '~> 4.1.0'
  gem 'jquery-rails'
  gem 'jbuilder', '~> 2.0'

  gem 'hamlbars'
  gem 'haml-rails'
  gem 'handlebars_assets'
  gem 'order_query'

  group :development do
    gem 'better_errors'
    gem 'binding_of_caller'
    gem 'quiet_assets'
    gem 'sdoc', '~> 0.4.0'
  end

  group :development, :test do
    gem 'factory_girl_rails'
    gem 'faker'
    gem 'pry-rails'
    gem 'pry-doc'
    gem 'pry-byebug'
    gem 'rspec-rails'
    gem 'spring'
    gem 'web-console', '~> 2.0'
  end

  group :test do
    gem 'shoulda-matchers', require: false
  end

  group :production do
    gem 'pg'
    gem 'rails_12factor'
  end
end

source 'https://rails-assets.org' do
  gem 'rails-assets-lodash'
  gem 'rails-assets-backbone'
  gem 'rails-assets-backbone.stickit'
end
