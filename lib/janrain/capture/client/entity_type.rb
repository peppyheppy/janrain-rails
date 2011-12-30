# http party client for entity
require 'httparty'
module Janrain::Capture::Client
  class EntityType
    include Janrain
    include HTTParty
    base_uri Config.capture.domain
    format :json

    # https://janraincapture.com/docs/api_entityType.html
    def self.show(options={})
      get("/entityType", query: defaults(options.delete(:type_name)))
    end

    # https://janraincapture.com/docs/api_entityType.list.html
    def self.list
      get("/entityType.list",
        query: defaults.delete_if { |key,val| key == :type_name }
      )
    end

    # https://janraincapture.com/docs/api_entityType.addAttribute.html
    def self.add_attribute(attrs={})
      type_name = attrs.delete(:type_name)
      constraints = attrs.delete(:constraints)
      add_attrs = defaults(type_name).merge(attr_def: attrs.to_json)
      #XXX: raise errors if name, type are nil
      results = get("/entityType.addAttribute", query: add_attrs)
      if constraints and results['stat'] == 'ok'
        results = set_attribute_constraints(attrs.merge(type_name: type_name, constraints: constraints))
      end
      results
    end

    def self.add_attributes(attrs=[])
      results = []
      attrs.each do |attr|
        results << add_attribute(attr)
      end
      results
    end

    # https://janraincapture.com/docs/api_entityType.setAttributeConstraints.html
    def self.set_attribute_constraints(attrs={})
      # XXX: raise errors if name, constraints are nil
      # validate the constraint names
      post("/entityType.setAttributeConstraints",
        query: defaults(attrs[:type_name]).
          merge(attribute_name: attrs[:name], constraints: attrs[:constraints].to_json)
      )
    end

    # https://janraincapture.com/docs/api_entityType.removeAttribute.html
    def self.remove_attribute(attrs={})
      # XXX: raise errors if name is nil
      get("/entityType.removeAttribute",
        query: defaults(attrs.delete(:type_name)).merge(attribute_name: attrs.delete(:name))
      )
    end

    private

    def self.defaults(type_name=nil)
      {
        type_name: type_name || Config.capture.entity['schema_type_name'],
        client_id: Config.capture.client_id,
        client_secret: Config.capture.client_secret,
      }
    end

  end
end
