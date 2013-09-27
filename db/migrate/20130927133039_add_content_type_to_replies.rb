class AddContentTypeToReplies < ActiveRecord::Migration
  def change
    add_column :replies, :content_type, :text, default: 'markdown'
    add_column :tickets, :content_type, :text, default: 'html'
  end
end
