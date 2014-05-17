class AddContentTypeToReplies < ActiveRecord::Migration
  def change
    add_column :replies, :content_type, :string, default: 'markdown'
    add_column :tickets, :content_type, :string, default: 'html'
  end
end
