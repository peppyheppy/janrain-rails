# http party client for entity
require 'httparty'
module Janrain::Capture::Client
  class Entity
    include Janrain
    include HTTParty
    base_uri Config.capture.domain
    format :json

    def self.by_token(token)
      get("/entity", {:headers => { 'Authorization' => "OAuth #{token}" }})
    end
  end
end
