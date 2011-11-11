# http party client for oath
require 'httparty'
module Janrain::Capture::Client
  class Oauth
    include Janrain
    include HTTParty
    base_uri Config.capture.domain
    format :json

    def self.token(code, options={})
      options.symbolize_keys!
      # XXX: support multiple grant types
      query = {
        code: code,
        redirect_uri: Config.capture.redirect_url,
        grant_type: 'authorization_code',
        client_id: Config.capture.client_id,
        client_secret: Config.capture.client_secret,
      }
      options[:query] = query.merge(options[:query] || {})
      get("/oauth/token", options)
    end
  end
end
