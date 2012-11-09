class Ticket < ActiveRecord::Base
  attr_accessible :content, :from, :subject
end
