require 'ostruct'
class Janrain::Config
  cattr_accessor :env
  cattr_accessor :root

  def self.configuration
    @@config ||= begin
      config = YAML::load_file(File.join(Rails.root, 'config', 'janrain.yml'))
      config[Rails.env] || raise(RuntimeError, "config/janrain.yml is missing or invalid.")
    end
  end

  def self.capture
    OpenStruct.new(configuration['capture']) || raise(RuntimeError, "config/janrain.yml does not appear to have capture settings.")
  end
end
