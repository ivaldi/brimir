class SetCorrectDefaultContentTypes < ActiveRecord::Migration
  def change
    change_column_default :replies, :content_type, 'html'
  end
end
