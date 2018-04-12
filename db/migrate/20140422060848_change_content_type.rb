class ChangeContentType < ActiveRecord::Migration[4.2]
  def change
    change_column :replies, :content_type, :string, default: 'markdown'
    change_column :tickets, :content_type, :string, default: 'html'
  end
end
