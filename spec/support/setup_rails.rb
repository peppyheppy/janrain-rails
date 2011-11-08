# load a rails app so we can test rails controllers,
# views, etc
class Application < Rails::Application
  config.active_support.deprecation = :stderr
end
Application.initialize!

# connect to sqlite db
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => "tmp/myapp.sqlite3")

# migrate if needed
class User < ActiveRecord::Base; end
class CreateTestUserModel < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :display_name
    end
  end

  def self.down
    drop_table :users
  end
end
CreateTestUserModel.down if User.table_exists?
CreateTestUserModel.up

# bogus controller for testing only
class FoobarController < ::ActionController::Base
  def test
    render :text => 'success'
  end
end

Rails.application.routes.draw do
  get '/test' => 'foobar#test', :as => :test
  root :to => "foobar#test"
end

