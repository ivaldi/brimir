class Attachment < ActiveRecord::Base
  attr_accessible :file

  # polymorphic relation with tickets & replies
  belongs_to :attachable, polymorphic: true

  has_attached_file :file #, styles: { thumb: [ '50x50#', :jpg ] }
end
