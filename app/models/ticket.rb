class Ticket < ActiveRecord::Base
  attr_accessible :content, :from, :subject, :status_id, :assignee_id

  validates_presence_of :status_id

  belongs_to :status
  belongs_to :assignee, class_name: 'User'
end
