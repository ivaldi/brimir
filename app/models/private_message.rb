class PrivateMessage < ActiveRecord::Base
  belongs_to :notifiable, polymorphic: true
  belongs_to :user
  belongs_to :ticket
  default_scope {order('created_at DESC')}
end
