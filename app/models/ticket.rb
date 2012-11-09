class Ticket < ActiveRecord::Base
  attr_accessible :content, :from, :subject

  belongs_to :status
end
