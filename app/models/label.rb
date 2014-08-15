class Label < ActiveRecord::Base
  has_many :labelings
  has_many :users, through: :labelings, source: :labelable, source_type: 'User'

  scope :ordered, -> {
    order(:name)
  }

  scope :viewable_by, ->(user){
    where(id: user.label_ids) unless user.agent?
  }
end
