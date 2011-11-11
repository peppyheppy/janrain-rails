# load a rails app so we can test rails controllers,
# views, etc
class Application < Rails::Application
  config.active_support.deprecation = :stderr
  config.root = Pathname.new(File.join(File.dirname(__FILE__), '..'))
end
Application.initialize!

# connect to sqlite db
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => "tmp/myapp.sqlite3")

# migrate if needed
class User < ActiveRecord::Base; end
class CreateTestUserModel < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.integer  :capture_id
      # entity fields on convention
      t.string   :email
      t.string   :display_name
      t.datetime :last_updated
      t.datetime :last_login
      # entity ignore columns
      t.string   :about_me
      # entity mappings
      t.string   :birthdate # from birthday
      # oauth/session fields
      t.string   :access_token, length: 40
      t.string   :refresh_token, length: 40
      t.datetime :expires_at
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

