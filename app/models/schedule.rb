class Schedule < ActiveRecord::Base

  has_one :user, dependent: :destroy

  has_and_belongs_to_many :work_days

  after_initialize :prefill_schedule, unless: :can_be_filled?

  def is_during_work?(time_in_hour, weekday)
    between_working_hours = working_hours.include?(time_in_hour)
    on_day = work_days.exists?(day: weekday)
    between_working_hours && on_day
  end

  def can_be_filled?
    WorkDay.exists?
  end

  def prefill_schedule
    days = []
    # days we want to create
    WorkDay.days.values[(0..6)].each do |day|
      days << day
    end

    WorkDay.create_default_work_days(days) unless days.empty?
  end

  def working_hours
    self.start.hour..self.end.hour
  end

  def today
    Time.zone.now.wday
  end

  # called from user_helper
  def add_default_work_days
    self.work_days = WorkDay.monday_to_friday
  end

  def start=(attribute)
    time = Time.zone.parse(attribute)
    write_attribute(:start, time)
  end

  def end=(attribute)
    time = Time.zone.parse(attribute)
    write_attribute(:end, time)
  end

end
