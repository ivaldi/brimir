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

class Attachment < ActiveRecord::Base
  attr_accessible :file

  # polymorphic relation with tickets & replies
  belongs_to :attachable, polymorphic: true

  has_attached_file :file, styles: { thumb: [ '50x50#', :jpg ] }
end
