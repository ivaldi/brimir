
# Brimir is a helpdesk system to handle email support requests.
# Copyright (C) 2012-2016 Ivaldi https://ivaldi.nl/
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

# labels attached via labelings to users or tickets
class Label < ActiveRecord::Base
  has_many :labelings, dependent: :destroy
  has_many :users, through: :labelings, source: :labelable, source_type: 'User'

  after_initialize :assign_random_color

  COLORS = [
    '#de6262',
    '#65a8dd',
    '#6fc681',
    '#9d61dd',
    '#6370dd',
    '#dca761',
    '#a86f72',
    '#759d91',
    '#727274'
  ]

  scope :ordered, lambda {
    order(:name)
  }

  scope :viewable_by, lambda { |user|
    if !user.agent? || user.labelings.count > 0
      where(id: user.label_ids)
    end
  }

  def assign_random_color
    self.color = Label::COLORS.sample if color.blank?
  end
end
