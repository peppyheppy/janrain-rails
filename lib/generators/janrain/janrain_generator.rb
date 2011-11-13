require 'rails/generators/active_record'

class JanrainGenerator < Rails::Generators::NamedBase
  include Rails::Generators::Migration

  source_root File.expand_path("../templates", __FILE__)
  desc "This generator copies a sample janrain.yml file, a controller, and some helpers."
  argument :controller_name, type: :string, required: false, default: 'session', banner: 'session'
  argument :attributes, type: :array, default: ['email:string', 'display_name:string'], banner: 'email:string display_name:string first_name:string last_name:string'

  def create_janrain_config
    template "janrain.yml.erb", "config/janrain.yml"
  end

  def generate_model
    invoke "active_record:model", [name], :migration => false unless model_exists? && behavior == :invoke
  end

  def add_janrain_to_model
    # add the janrain module/concerns to the model
    inject_into_class(model_path, class_name, <<-CONTENT) if model_exists?
  include Janrain::Capture::User
    CONTENT
  end

  def add_model_migration
    # if the model already exists, then render the
    if (behavior == :invoke && model_exists?) || (behavior == :revoke && migration_exists?(table_name))
      migration_template "migration_existing.rb", "db/migrate/add_janrain_to_#{table_name}"
    else
      migration_template "migration.rb", "db/migrate/janrain_create_#{table_name}"
    end
  end

  def add_controllers
    # add a controller named after the argument controller_name
    # someting like this, but make sure we add:
    # include Janrain::Capture::Controller
    # then we should make sure we append:
    # include Janrain::Capture::Authentication
    # invoke "active_record:model", [name], :migration => false unless model_exists? && behavior == :invoke
  end

  def add_routes_for_controller
    # for the controller_name we need to add routes for:
    # resource :session, only: [:new, :create, :destroy] # signin, signout
  end

  # XXX: add generator for user model, controller, and helper

  hook_for :test_framework
  hook_for :orm

  def self.next_migration_number(dirname)
    ActiveRecord::Generators::Base.next_migration_number(dirname)
  end

  private

  def model_exists?
    File.exists?(File.join(destination_root, model_path))
  end

  def model_path
    @model_path ||= File.join("app", "models", "#{file_path}.rb")
  end

  def migration_exists?(table_name)
    Dir.glob("#{File.join(destination_root, migration_path)}/[0-9]*_*.rb").grep(/\d+_add_devise_to_#{table_name}.rb$/).first
  end

  def migration_path
    @migration_path ||= File.join("db", "migrate")
  end

end
