class AddAgentAndSignatureToUser < ActiveRecord::Migration
  def change
    add_column :users, :agent, :boolean
    add_column :users, :signature, :text
  end
end
