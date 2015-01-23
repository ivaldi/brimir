class JiraTicket
  include ActiveModel::Model

  attr_accessor :project, :description, :title, :id

  validates :project, presence: true
  validates :title, presence: true

end