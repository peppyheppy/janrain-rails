require 'rubygems'
require 'bundler/setup'
require 'artifice'
require 'janrain'
require "action_controller/railtie"
require 'rspec/rails'
require 'rspec/mocks'
require 'rspec/rails/mocks'
require 'support/setup_rails'

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
Artifice.activate_with(JanrainAPI.new)

