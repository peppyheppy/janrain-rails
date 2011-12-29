module Janrain::Capture::User
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods
    include Janrain::Capture
    def authenticate(code, options={})
      # XXX: lets support password auth at some point
      oauth = Client::Oauth.token(code, options)
      if oauth['stat'] == 'ok'
        entity = Client::Entity.by_token(oauth['access_token'])
        user = find_or_initialize_by_capture_id(entity['result']['id'])
        if user.update_attributes(entity: entity, oauth: oauth)
          return user
        end
      end
      false
    end
  end

  def to_capture(only_changes=false)
    dup_attributes = if only_changes
      self.attributes.dup.keep_if { |k,v| self.changes.key? k }
    else
      self.attributes.dup
    end
    attrs = dup_attributes.inject({}) do |all, (key, value)|
      capture_key = (Janrain::Config.capture.entity['mappings'].key(key) || key).to_s
      unless (Janrain::Config.capture.entity['ignore_columns'] || []).include?(capture_key)
        all[capture_key] = value
      end
      all
    end

    if capture_id.blank?
      attrs.delete_if { |a,v| a == 'id' || a == 'capture_id' }
    end
    attrs
  end

  def persist_to_capture(only_changes = false)
    params = self.to_capture(only_changes)
    if not params.blank?
      response = {}
      if capture_id.blank?
        response = Janrain::Capture::Client::Entity.create(params) unless params.blank?
      else
        response = Janrain::Capture::Client::Entity.update(capture_id, params)
      end
      response['stat'] == 'ok'
    else
      true # nothing to update
    end
  end

  def change_privileges(up_or_down)
    up_or_down = up_or_down.to_s.try(:to_sym)

    if up_or_down == :down
      if self.superuser?
        self.update_attribute(:superuser, false)
      elsif self.admin?
        self.update_attribute(:admin, false)
      end
    elsif up_or_down == :up
      if not self.admin?
        self.update_attribute(:admin, true)
      elsif self.admin?
        self.update_attribute(:superuser, true)
      end
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
