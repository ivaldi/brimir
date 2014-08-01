# Brimir is a helpdesk system to handle email support requests.
# Copyright (C) 2012-2014 Ivaldi http://ivaldi.nl
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

class Ticket < ActiveRecord::Base
  include CreateFromUser

  validates_presence_of :user_id

  belongs_to :user
  belongs_to :assignee, class_name: 'User'

  has_many :attachments, as: :attachable, dependent: :destroy
  has_many :replies, dependent: :destroy
  has_many :labelings, as: :labelable
  has_many :labels, through: :labelings

  enum status: [:open, :closed, :deleted]
  enum priority: [:unknown, :low, :medium, :high]

  scope :by_label_id, ->(label_id) {
    if label_id.to_i > 0
      joins(:labelings)
          .where(labelings: { label_id: label_id })
    end
  }

  scope :by_status, ->(status) {
    where(status: Ticket.statuses[status.to_sym])
  }

  scope :filter_by_assignee_id, ->(assignee_id) {
    if !assignee_id.nil?
      if assignee_id.to_i == 0
        where(assignee_id: nil)
      else
        where(assignee_id: assignee_id)
      end
    else
      all
    end
  }

  scope :search, ->(term) {
    if !term.nil?
      term = '%' + term.downcase + '%'
      where('LOWER(subject) LIKE ? OR LOWER(content) LIKE ?',
          term, term)
    end
  }

  scope :ordered, -> {
    order(:created_at).reverse_order
  }

  scope :viewable_by, ->(user) {
    if !user.agent?
      joins('LEFT JOIN labelings ON tickets.id = labelings.labelable_id')
        .where('(labelings.label_id = ? AND labelings.labelable_type = ?) ' +
            ' OR user_id = ?', user.label_ids, 'Ticket', user.id)
    end
  }
end
