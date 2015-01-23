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

class JiraTicketsController < ApplicationController

	load_and_authorize_resource :jira_ticket

  def new
		# Show all projects
		@ticket = Ticket.find(params[:ticket_id])
		@projects = get_client().Project.all
		@jira_ticket = JiraTicket.new
		@jira_ticket.title = @ticket.subject
		@jira_ticket.description = @ticket.content
  end

  def create
  	@jira_ticket = JiraTicket.new(ticket_params)
  	issue = get_client().Issue.build
    byebug
		issue.save({"fields"=>{"summary"=>@jira_ticket.title,"description" =>@jira_ticket.description,"project"=>{"id"=>@jira_ticket.project},"issuetype"=>{"id"=>"3"}}})
		redirect_to tickets_path
  end

  protected
  	def ticket_params
      params.require(:jira_ticket).permit(
          :title,
          :description,
          :project,
      )
    end

  	def get_client
  		options = {
            :username => '',
            :password => '',
            :site     => '',
            :context_path => '',
            :auth_type => :basic,
            :use_ssl => true
          }

			client = JIRA::Client.new(options)
  	end

end