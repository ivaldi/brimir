RAILS_ROOT = "/home/brimir/brimir"
RAILS_ENV = ENV['RAILS_ENV'] || "development"

God.watch do |w|
  w.name = "unicorn"
  w.interval = 15.seconds

  w.start = "/bin/bash -c 'cd #{RAILS_ROOT}; unicorn --env #{RAILS_ENV} --daemonize -c #{RAILS_ROOT}/config/unicorn.rb'"
  w.stop = "kill -QUIT `cat #{RAILS_ROOT}/tmp/pids/unicorn.pid`"
  w.restart = "kill -USR2 `cat #{RAILS_ROOT}/tmp/pids/unicorn.pid`"
  w.log = "#{RAILS_ROOT}/log/god_unicorn.log"
  w.start_grace = 30.seconds
  w.restart_grace = 30.seconds
  w.pid_file = "#{RAILS_ROOT}/tmp/pids/unicorn.pid"

  w.behavior(:clean_pid_file)

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running = false
    end
  end

  w.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above = 300.megabytes
      c.times = [3, 5] # 3 out of 5 intervals
    end

    restart.condition(:cpu_usage) do |c|
      c.above = 50.percent
      c.times = 5
    end
  end

  # lifecycle
  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
end
