class Reply < ActiveRecord::Base
  attr_accessible :content, :ticket_id

  validates_presence_of :content

  belongs_to :ticket

  has_many :attachments, as: :attachable, dependent: :destroy
end
