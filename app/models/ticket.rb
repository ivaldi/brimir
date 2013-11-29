# Brimir is a helpdesk system to handle email support requests.
# Copyright (C) 2012 Ivaldi http://ivaldi.nl
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

  validates_presence_of :status_id, :user_id

  belongs_to :user
  belongs_to :status
  belongs_to :priority
  belongs_to :assignee, class_name: 'User'

  has_many :attachments, as: :attachable, dependent: :destroy

  has_many :replies, dependent: :destroy

  scope :filter_by_search, -> (searched_for) { where('LOWER(subject) LIKE ? OR LOWER(content) LIKE ?', 
      '%' + searched_for.downcase + '%', '%' + searched_for.downcase + '%') }

  def self.filter_by_assignee_id(assignee_id)
    if !assignee_id.nil?
      if assignee_id.to_i == 0
        where(assignee_id: nil)
      else
        where(assignee_id: assignee_id)
      end
    else
      all
    end
  end
end
