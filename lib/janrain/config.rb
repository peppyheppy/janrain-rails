require 'ostruct'
require 'uri'
class Janrain::Config

  def self.configuration
    @@config ||= begin
      config = YAML::load_file(File.join(Rails.root, 'config', 'janrain.yml'))
      config[Rails.env] || raise(RuntimeError, "config/janrain.yml is missing or invalid.")
    end
  end

  def self.capture
    OpenStruct.new(configuration['capture']) || raise(RuntimeError, "config/janrain.yml does not appear to have capture settings.")
  end

  def self.model
    self.capture.model.constantize
  end

  def self.controller
    self.capture.controller
  end

  def self.redirect_url(options={})
    options.symbolize_keys!
    uri = URI.parse(options.delete(:url) || capture.redirect_url)
    if host = options.delete(:host)
      uri.host = host.split(':').first
    end
    if return_to = options.delete(:return_to)
      delim = uri.query.blank? ? '' : '&'
      uri.query = "#{uri.query}#{delim}return_to=#{CGI.escape(return_to)}"
    end
    uri.to_s
  end

  def self.within_iframe?
    !!self.capture.within_iframe
  end

end
