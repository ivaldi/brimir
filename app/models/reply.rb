# Brimir is a helpdesk system to handle email support requests.
# Copyright (C) 2012-2015 Ivaldi https://ivaldi.nl/
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# replies to tickets, made by a user, possibly with attachments
class Reply < ActiveRecord::Base
  include CreateFromUser
  include EmailMessage
  include ReplyNotifications

  attr_accessor :reply_to_id
  attr_accessor :reply_to_type

  validates :ticket_id, :content, presence: true

  belongs_to :ticket, touch: true
  belongs_to :user

  accepts_nested_attributes_for :ticket

  scope :chronologically, -> { order(:created_at) }
  scope :with_message_id, lambda {
    where.not(message_id: nil)
  }

  scope :without_drafts, -> {
    where(draft: false)
  }

  scope :unlocked_for, ->(user) {
    joins(:ticket)
        .where('locked_by_id IN (?) OR locked_at < ?',
            [user.id, nil], Time.zone.now - 5.minutes)
  }

  def reply_to
    reply_to_type.constantize.where(id: self.reply_to_id).first if reply_to_type
  end

  def reply_to=(value)
    self.reply_to_id = value.id
    self.reply_to_type = value.class.name
  end

  def other_replies
    ticket.replies.where.not(id: id)
  end
  
  def first?
    reply_to_type == 'Ticket'
  end
end
