require 'spec_helper'
require "generator_spec/test_case"
require 'generators/janrain/janrain_generator'
require 'fileutils'

def setup_route_and_controller_fixtures(destination_root)
  # routes setup
  config = ::File.join(destination_root, 'config')
  ::Dir.mkdir(config)
  ::FileUtils.cp(::File.join('spec', 'fixtures','routes.rb'), ::File.join(config, 'routes.rb'))

  # application controller setup
  config = ::File.join(destination_root, 'app', 'controllers')
  ::FileUtils.mkdir_p(config)
  ::FileUtils.cp(::File.join('spec', 'fixtures','application_controller.rb'), ::File.join(config, 'application_controller.rb'))
end

describe JanrainGenerator do
  include GeneratorSpec::TestCase
  destination File.expand_path("../../../../../tmp_app", __FILE__)
  arguments %w(user session foo:string bar:integer)
  tests JanrainGenerator

  before do
    prepare_destination
    setup_route_and_controller_fixtures(destination_root)
    run_generator
  end

  it "should generate the janrain config" do
    destination_root.should have_structure {
      no_file "janrain.yml"
      directory "config" do
        file "janrain.yml" do
          contains "# this file was originally generated by the janrain-rails generator"
          contains "capture"
          contains "client_secret"
          contains "client_id"
          contains "domain"
          contains "redirect_url"
          contains "/session/new"
        end
      end
    }
  end

  it "should generate the janrain config" do
    destination_root.should have_structure { # note { not 'do' needs to be used or fail
      directory "app" do
        directory "models" do
          file "user.rb" do
            contains "class User < ActiveRecord::Base"
            contains "include Janrain::Capture::User"
            contains "include Bitfields"
            contains "bitfield :permissions,"
            contains "bitfield :flags,"
            contains ":admin"
            contains ":superuser"
            contains "end"
          end
        end
      end
    }
  end

  it "should add routes" do
    destination_root.should have_structure { # note { not 'do' needs to be used or fail
      directory "config" do
        file "routes.rb" do
          contains "get '/session/signup'"
          contains "new_janrain_session"
          contains "janrain_signout"
        end
      end
    }
  end

  it "should add controller" do
    destination_root.should have_structure { # note { not 'do' needs to be used or fail
      directory "app" do
        directory "controllers" do
          file "session_controller.rb" do
            contains "SessionController"
            contains "@user = User"
            contains "def new"
            contains "def create"
            contains "def destroy"
          end
        end
      end
    }
  end

  describe "existing model" do
    before do
      JanrainGenerator.stub(:next_migration_number).and_return('20111113050103')
      prepare_destination
      setup_route_and_controller_fixtures(destination_root)
      # a bit of hackery to get th code to run in real life the way it should.
      FileUtils.mkdir_p(::File.join(destination_root, 'app', 'models'))
      ::File.open(::File.join(destination_root, 'app', 'models', 'user.rb'), 'w') {|f| f.write("class User; end") }
      run_generator
    end

    it "should generate the migration" do
      destination_root.should have_structure { # note { not 'do' needs to be used or fail
        directory "db" do
          directory "migrate" do
            file "20111113050103_add_janrain_to_users.rb" do
              contains "class AddJanrainToUser"
              contains "capture_id, unique: true"
              contains "t.string :foo"
              contains "change_table(:users)"
            end
          end
        end
      }
    end
  end

  describe "non-existing model" do
    before do
      JanrainGenerator.stub(:next_migration_number).and_return('20111113050103')
      prepare_destination
      setup_route_and_controller_fixtures(destination_root)
      run_generator
    end

    it "should generate the migration" do
      destination_root.should have_structure { # note { not 'do' needs to be used or fail
        directory "db" do
          directory "migrate" do
            file "20111113050103_janrain_create_users.rb" do
              contains "class JanrainCreateUsers"
              contains "capture_id, unique: true"
              contains "t.string :foo"
              contains "create_table(:users)"
            end
          end
        end
      }
    end
  end

end

