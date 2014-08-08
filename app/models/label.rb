class Label < ActiveRecord::Base
  has_many :labelings

  scope :ordered, -> {
    order(:name)
  }

  scope :viewable_by, ->(user){
    where(id: user.label_ids) unless user.agent?
  }
end
