class Labeling < ActiveRecord::Base
  belongs_to :label
  belongs_to :labelable, polymorphic: true
end
