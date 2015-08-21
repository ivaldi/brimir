class AddPlainTextPreferenceToUser < ActiveRecord::Migration
  def change
    add_column :users, :prefer_plain_text, :boolean, default: false, null: false
  end
end
