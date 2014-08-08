class Label < ActiveRecord::Base
  has_many :labelings

  scope :ordered, -> {
    order(:name)
  }
end
