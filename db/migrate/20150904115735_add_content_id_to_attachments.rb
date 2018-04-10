class AddContentIdToAttachments < ActiveRecord::Migration[4.2]
  def change
    add_column :attachments, :content_id, :string
  end
end
