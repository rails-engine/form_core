# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Declare your gem"s dependencies in form_core.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

gem "activeentity", path: "../activeentity"

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

gem "rails", "~> 7.0.0"
gem "sqlite3"

# To support ES6
gem "sprockets", "~> 4.0"
# Support ES6
gem "babel-transpiler"
# Use CoffeeScript for .coffee assets and views
# gem "coffee-rails", "~> 4.2"
# Use SCSS for stylesheets
gem "sassc-rails"
# Use Uglifier as compressor for JavaScript assets
gem "uglifier", ">= 1.3.0"

gem "bulma-rails"
gem "jquery-rails"
gem "selectize-rails"
gem "turbolinks"

# Use Puma as the app server
gem "puma"

# Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
gem "listen", ">= 3.2"
gem "web-console", group: :development
# Call "byebug" anywhere in the code to stop execution and get a debugger console
gem "byebug", platforms: %i[mri mingw x64_mingw]

gem "timeliness-i18n"
gem "validates_timeliness", "~> 5.0.0.alpha1"

gem "acts_as_list"
gem "cocoon"

gem "rubocop"
gem "rubocop-performance"
gem "rubocop-rails"
