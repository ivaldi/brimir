class Labeling < ActiveRecord::Base
  belongs_to :label
  belongs_to :labelable, polymorphic: true

  validates_uniqueness_of :label_id, scope: [:labelable_id, :labelable_type]

  def initialize(attributes)
    unless attributes[:label].blank? ||
        attributes[:label][:name].blank?

      label = Label.where(name: attributes[:label][:name]).first_or_create!

      attributes.delete(:label)
      attributes[:label_id] = label.id
    end

    super(attributes)
  end
end
