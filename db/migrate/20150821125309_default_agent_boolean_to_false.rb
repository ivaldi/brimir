class DefaultAgentBooleanToFalse < ActiveRecord::Migration
  def change
    User.where(agent: nil).update_all(agent: false)
    change_column :users, :agent, :boolean, default: false, null: false
  end
end
