class Label < ActiveRecord::Base
  has_many :labelings, dependent: :destroy
  has_many :users, through: :labelings, source: :labelable, source_type: 'User'

  after_initialize :assign_random_color

  COLORS = [
          '#de6262',
          '#65a8dd',
          '#6fc681',
          '#9d61dd',
          '#6370dd',
          '#dca761',
          '#a86f72',
          '#759d91',
          '#727274'
  ]

  scope :ordered, -> {
    order(:name)
  }

  scope :viewable_by, ->(user){
    where(id: user.label_ids) unless user.agent?
  }

  def assign_random_color
    if self.color.blank?
      self.color = Label::COLORS.sample
    end
  end
end
