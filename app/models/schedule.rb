class Schedule < ActiveRecord::Base

  has_one :user, dependent: :destroy

  def is_during_work?(time_in_zone_for_user)
    wday = time_in_zone_for_user.wday
    is_on_day?(wday) && working_hours.cover?(time_in_zone_for_user)
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
    self.start..self.end
  end

  def start
    if user.nil?
      read_attribute(:start)
    else
      read_attribute(:start).in_time_zone(user.time_zone)
    end
  end

  def end
    if user.nil?
      read_attribute(:end)
    else
      read_attribute(:end).in_time_zone(user.time_zone)
    end
  end

  def start=(attribute)
    time = Time.parse(attribute)
    write_attribute(:start, time)
  end

  def end=(attribute)
    time = Time.parse(attribute)
    write_attribute(:end, time)
  end

end
