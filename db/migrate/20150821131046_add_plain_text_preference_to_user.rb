class AddPlainTextPreferenceToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :prefer_plain_text, :boolean, default: false, null: false
  end
end
