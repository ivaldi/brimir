class Schedule < ActiveRecord::Base

  has_one :user, dependent: :destroy

  def is_during_work?(time_in_hour, weekday)
    between_working_hours = working_hours.include?(time_in_hour)
    on_day = is_on_day?(weekday)
    between_working_hours && on_day
  end

  def is_on_day?(weekday)
    case weekday
    when 0
      sunday?
    when 1
      monday?
    when 2
      tuesday?
    when 3
      wednesday?
    when 4
      thursday?
    when 5
      friday?
    when 6
      saturday?
    else
      false
    end
  end

  def working_hours
    self.start.hour..self.end.hour
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
