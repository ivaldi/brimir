class AddContentIdToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :content_id, :string
  end
end
