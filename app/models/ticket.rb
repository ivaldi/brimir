class Ticket < ActiveRecord::Base
  attr_accessible :content, :from, :subject, :status_id, :assignee_id

  validates_presence_of :status_id

  belongs_to :status
  belongs_to :assignee, class_name: 'User'

  has_many :attachments, as: :attachable, dependent: :destroy

  has_many :replies, dependent: :destroy
end
