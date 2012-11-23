class Reply < ActiveRecord::Base
  attr_accessible :content, :ticket_id, :message_id, :user_id

  validates_presence_of :content

  belongs_to :ticket
  belongs_to :user

  has_many :attachments, as: :attachable, dependent: :destroy
end
