class Ticket < ActiveRecord::Base
  attr_accessible :content, :user_id, :subject, :status_id, :assignee_id, :message_id

  validates_presence_of :status_id

  belongs_to :user
  belongs_to :status
  belongs_to :assignee, class_name: 'User'

  has_many :attachments, as: :attachable, dependent: :destroy

  has_many :replies, dependent: :destroy
end
