class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.references :attachable
      t.string :attachable_type

      t.timestamps
    end
    add_index :attachments, :attachable_id
  end
end
