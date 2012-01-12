module Janrain::Capture::User
  extend ActiveSupport::Concern

  included do
    before_validation :default_permissions_and_flags_if_nil
    before_save :update_capture_with_changes
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
      attrs.delete_if { |a,v| a == 'id' || a == 'capture_id'}
    end
    attrs
  end

  def persist_to_capture(only_changes = false,  persist = true)
    begin
      params = self.to_capture(only_changes)
      if params.present?
        response = {}
        existing_user = nil
        email_existing = Janrain::Capture::Client::Entity.find("email = '#{email}'")['results'].first

        # new user in local system will update remote capture and set capture_id if remote
        #   - capture_id is nil; existing is set; existing_user is nil
        #
        # new user in both systems will create new capture and set capture_id
        #   - capture_id is nil; existing is nil; existing_user is nil
        #
        # existing in both systems will update capture
        #   - capture_id is set; existing is set; existing_user is set

        if self.capture_id or email_existing
          if email_existing and not self.capture_id
            # verify
            if existing_user = User.find_by_capture_id(email_existing['id']) and
              self.id != existing_user.id
            then
              raise "Janrain::Capture (user inconsistancy) an attempt to create a duplicate user was made."
            end
            self.capture_id = email_existing['id']
          end
          # update
          response = Janrain::Capture::Client::Entity.update(capture_id, params)
        else
          # create
          response = Janrain::Capture::Client::Entity.create(params)
          self.capture_id = response['id']
        end

        if persisted? and persist
          if response['stat'] == 'ok'
            update_attribute(:failed, false)
            update_attribute(:capture_id, self.capture_id)
          else
            update_attribute(:failed, true)
          end
        else
          if response['stat'] == 'ok'
            self[:failed] = false
            self[:capture_id] = self.capture_id
          else
            self[:failed] = true
          end
        end
        # return capture id
        self.capture_id
      else
        self.capture_id # nothing to update
      end
    rescue => e
      if persisted? and persist
        update_attribute(:failed, true)
      else
        self[:failed] = true
      end
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

  def update_capture_with_changes
    persist_to_capture(only_changes = true, persist = false)
  end

  def default_permissions_and_flags_if_nil
    self[:permissions] = 0 if permissions.blank?
    self[:flags]= 0 if flags.blank?
  end

end
