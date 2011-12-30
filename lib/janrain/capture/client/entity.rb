# http party client for entity
require 'httparty'
module Janrain::Capture::Client
  class Entity
    include Janrain
    include HTTParty
    base_uri Config.capture.domain
    format :json

    # https://janraincapture.com/docs/api_entity.html
    def self.by_token(token, options={})
      get("/entity", headers: { 'Authorization' => "OAuth #{token}" })
    end

    # https://janraincapture.com/docs/api_entity.html
    def self.by_id(id, overrides={})
      attrs = defaults.merge(overrides)
      get("/entity", query: attrs.merge(id: id))
    end

    # https://janraincapture.com/docs/api_entity.count.html
    def self.count(overrides={})
      get("/entity.count", query: defaults.merge(overrides))
    end

    # https://janraincapture.com/docs/api_entity.create.html
    # returns the new id
    def self.create(attrs={})
      params = defaults
      if type_name = attrs.delete(:type_name)
        params = defaults.merge(type_name: type_name)
      end
      post("/entity.create", query: params.merge(attributes: attrs.to_json))
    end

    # https://janraincapture.com/docs/api_entity.bulkCreate.html
    # returns an array of ids and/or errors
    def self.bulk_create(new_entities=[], overrides={})
      post("/entity.bulkCreate", query: defaults.
        merge(overrides).
        merge(all_attributes: new_entities.to_json))
    end

    # https://janraincapture.com/docs/api_entity.delete.html
    # XXX: does not support plural deletion, nor created/lastUpdated date
    # checks. Its a sharp delete -- don't hurt yourself!
    def self.delete(id, overrides={})
      attrs = defaults.merge(overrides)
      post("/entity.delete", query: attrs.merge(id: id))
    end

    # https://janraincapture.com/docs/api_entity.update.html
    # XXX: does not support advanced variations of update
    def self.update(id, attrs={})
      params = defaults
      if type_name = attrs.delete(:type_name)
        params = defaults.merge(type_name: type_name)
      end
      post("/entity.update", query: params.merge(id: id, attributes: attrs.to_json))
    end

    # XXX: not supporting replace.... don't have a real case for it yet
    # https://janraincapture.com/docs/api_entity.replace.html

    # https://janraincapture.com/docs/api_entity.find.html
    def self.find(filter, options={})
      params = defaults.merge(filter: filter).merge(options)
      get('/entity.find', query: params)
    end

    private

    def self.defaults
      {
        type_name: Config.capture.entity['schema_type_name'],
        client_id: Config.capture.client_id,
        client_secret: Config.capture.client_secret,
      }
    end

  end
end
