# see support/setup_rails which is loaded before this is loaded

# include janrain user concerns into test user
class TestUser < ActiveRecord::Base
  include Janrain::Capture::User
end

# create the application controller that would otherwise be
# defined within a rails application
class ApplicationController < ActionController::Base
  prepend_view_path File.join(File.dirname(__FILE__), '..', 'fixtures', 'views')
  include Janrain::Authentication
  def index
    render :text => 'hello'
  end
end

# locals that would be set by the generator
controller_name = 'Session'
name = 'test_user'
class_name = name.camelize
singular_name = name

# load the controller template
template = ERB.new(open('lib/generators/janrain/templates/controller.rb').read)
eval(template.result(binding))

# XXX: it would be great to use the same routes that we are creating for the resource
Rails.application.routes.draw do
  get '/urls' => 'application#index'
  get '/foobars/new' => 'foobars#new'
  get '/foobars/edit' => 'foobars#edit'
  resources :admin
  get '/session/signup' => 'session#new', :as => :new_janrain_session
  get '/session/signin' => 'session#create'
  get '/session/signout' => 'session#destroy', :as => :janrain_signout
  root :to => "session#create"
end


