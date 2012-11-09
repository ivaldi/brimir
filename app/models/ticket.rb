class Ticket < ActiveRecord::Base
  attr_accessible :content, :from, :subject, :status_id

  validates_presence_of :status_id

  belongs_to :status
end
