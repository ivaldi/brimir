class WorkDay < ActiveRecord::Base

  enum day: [:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday]
  has_and_belongs_to_many :schedules

  def self.create_default_work_days(days)
    days.each do |day|
      create({ day: day })
    end
  end

  def self.monday_to_friday
    where(day: (1..5))
  end

  def translated_day
    I18n.t(day, scope: :week_days)
  end
end
