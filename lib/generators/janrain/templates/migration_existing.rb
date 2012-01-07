class AddJanrainTo<%= table_name.camelize %> < ActiveRecord::Migration
  def self.up
    change_table(:<%= table_name %>) do |t|
      t.integer :capture_id, unique: true, null: false
      t.integer :flags, :default => 0
      t.integer :permissions, :default => 0
      t.string :email, null: false
      t.string :display_name, null: false
      # add additional fields here
<% attributes.each do |attribute| -%>
   <% next if ['email', 'display_name'].include?(attribute.name.to_s) -%>
   t.<%= attribute.type %> :<%= attribute.name %>
<% end -%>
      # session specific fields
      t.string :access_token
      t.string :refresh_token
      t.datetime :expires_at
      t.timestamps
    end

    add_index :<%= table_name %>, :capture_id,  :unique => true
    add_index :<%= table_name %>, :access_token
    add_index :<%= table_name %>, :expires_at
  end

  def self.down
  end
end
