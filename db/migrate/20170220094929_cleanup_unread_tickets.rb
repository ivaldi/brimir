class CleanupUnreadTickets < ActiveRecord::Migration[5.0]
  class TicketsUser < ApplicationRecord
    belongs_to :user
  end

  def change
    TicketsUser.where(user: User.where(agent: false)).delete_all
  end
end
