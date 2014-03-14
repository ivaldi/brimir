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

class AttachmentsController < ApplicationController

  load_and_authorize_resource :attachment
  
  def show
    begin
      if params[:format] == 'thumb'
        send_file @attachment.file.path(:thumb),
            type: 'image/jpeg',
            disposition: :inline
      else
        send_file @attachment.file.path,
            filename: @attachment.file_file_name,
            type: @attachment.file_content_type,
            disposition: :attachment
      end
    rescue ActionController::MissingFile
      render text: 'File not found.', status: :not_found
    end
  end

end
