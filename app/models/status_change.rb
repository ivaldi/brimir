class StatusChange < ActiveRecord::Base
  belongs_to :ticket
  enum status: Ticket.statuses

  scope :ordered, -> {
    order(:created_at)
  }
end
