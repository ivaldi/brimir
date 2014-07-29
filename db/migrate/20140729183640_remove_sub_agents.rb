class RemoveSubAgents < ActiveRecord::Migration
  def change
    # convert sub agents to normal customers
    User.where.not(incoming_address: nil).each do |user|
      user.agent = false
      user.save! validates: false
    end

    remove_column :users, :incoming_address
    remove_column :tickets, :to
  end
end
