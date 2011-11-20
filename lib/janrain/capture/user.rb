module Janrain::Capture::User
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods
    include Janrain::Capture
    def authenticate(code)
      # XXX: lets support password auth at some point
      $stdout.puts "*" * 20
      oauth = Client::Oauth.token(code)
      $stdout.puts "oauth: #{oauth.inspect}"
      if oauth['stat'] == 'ok'
        entity = Client::Entity.by_token(oauth['access_token'])
        $stdout.puts "entity: #{entity.inspect}"
        user = find_or_initialize_by_capture_id(entity['result']['id'])
        $stdout.puts "user: #{user.inspect}"
        if user.update_attributes(entity: entity, oauth: oauth)
          $stdout.puts "user update: #{user.inspect}"
          return user
        end
      end
      $stdout.puts "*" * 20
      false
    end
  end

  def entity=(entity)
    result = entity['result']
    # TODO: update existing cache fields
    # 4) if the column exists in mappings then update
    result.each do |original_column, value|
      # map the capture id
      original_column = 'capture_id' if original_column == 'id'

      new_column_name = original_column.underscore

      # handle the mapped columns
      if mapped_column_name = (Janrain::Config.capture.entity['mappings'] || {})[original_column]
        new_column_name = mapped_column_name
      end

      # skip columns
      next if (Janrain::Config.capture.entity['ignore_columns'] || []).include?(original_column) or not
        self.attributes.include?(new_column_name)

      self[new_column_name] = value
    end
  end

  def oauth=(oauth)
    self[:refresh_token] = oauth['refresh_token']
    self[:access_token] = oauth['access_token']
    self[:expires_at] = Time.now + oauth['expires_in'].seconds
  end

  private
end
