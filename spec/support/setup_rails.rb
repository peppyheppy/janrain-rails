# load a rails app so we can test rails controllers,
# views, etc
class Application < Rails::Application
  config.active_support.deprecation = :stderr
  config.root = Pathname.new(File.join(File.dirname(__FILE__), '..'))
end
Application.initialize!

# connect to sqlite db
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => "tmp/myapp.sqlite3")

# create test user
class TestUser < ActiveRecord::Base
end

# migrate if needed
class CreateTestUserModel < ActiveRecord::Migration
  def self.up
    create_table :test_users do |t|
      t.integer  :capture_id, null: false
      t.integer  :preferences, default: 0
      t.integer  :permissions, default: 0
      # entity fields on convention
      t.string   :email, null: false
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
    drop_table :test_users
  end
end
CreateTestUserModel.down if TestUser.table_exists?
CreateTestUserModel.up


