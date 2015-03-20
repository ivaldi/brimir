# Brimir is a helpdesk system to handle email support requests.
# Copyright (C) 2012-2015 Ivaldi http://ivaldi.nl
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

  before_filter :authenticate_user!, except: [:create, :new]
  load_and_authorize_resource :attachment, except: :show

  def show
    @attachment = Attachment.find(params[:id])

    if @attachment.attachable_type == 'Ticket'
      authorize! :read, @attachment.attachable
    else
      authorize! :read, @attachment.attachable.ticket
    end

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
      render text: I18n::translate(:file_not_found), status: :not_found
    end
  end
end
