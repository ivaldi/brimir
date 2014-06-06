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

class Attachment < ActiveRecord::Base
  # polymorphic relation with tickets & replies
  belongs_to :attachable, polymorphic: true

  has_attached_file :file,
      path: ':rails_root/data/:class/:attachment/:id_partition/:style.:extension',
      url: '/attachments/:id/:style',
      styles: {
          thumb: {
              geometry: '50x50#',
              format: :jpg,
              # this will convert transparent parts to white instead of black
              convert_options: '-flatten'
          }
      }
  do_not_validate_attachment_file_type :file
  before_post_process :image?

  def image?
    !file_content_type.match(/^image/).nil? || !file_content_type.match(/pdf$/).nil?
  end
end
