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

module EmailMessage
  extend ActiveSupport::Concern

  included do
    has_many :attachments, as: :attachable, dependent: :destroy
    accepts_nested_attributes_for :attachments, allow_destroy: true

    has_many :attached_files, -> { where(content_id: nil) }, as: :attachable, class_name: 'Attachment'
    has_many :inline_files, -> { where.not(content_id: nil) }, as: :attachable, class_name: 'Attachment'

    has_attached_file :raw_message,
        path: Tenant.files_path

    do_not_validate_attachment_file_type :raw_message
  end
end
