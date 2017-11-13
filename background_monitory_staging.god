God.watch do |w|
  w.name   = "backburner-staging"
  w.dir    = '/var/www/inova-crm/current'
  w.env = { 'RAILS_ENV' => 'production', 'QUEUES' => 'backburner-jobs,index-model' }
  w.group    = 'backburner-workers'
  w.interval = 900.seconds
  w.start = "/usr/local/rvm/bin/rvm ruby-2.2.0@rails_4_2_1 do bundle exec rake -f Rakefile backburner:work RAILS_ENV=staging QUEUE=backburner-jobs,index-model"
  w.log   = "/var/www/inova-crm/shared/log/backburner-staging.log"

  # restart if memory gets too high
  w.transition(:up, :restart) do |on|
    on.condition(:memory_usage) do |c|
      c.above = 1000.megabytes
      c.times = 3
    end
  end

  # determine the state on startup
  w.transition(:init, { true => :up, false => :start }) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end

  # determine when process has finished starting
  w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
      c.running = true
      c.interval = 10.seconds
    end

    # failsafe
    on.condition(:tries) do |c|
      c.times = 5
      c.transition = :start
      c.interval = 5.seconds
    end
  end

  # start if process is not running
  w.transition(:up, :start) do |on|
    on.condition(:process_running) do |c|
      c.running = false
    end
  end
end

# god stop backburner-worker-1
# god -c path/to/background_monitor.god -D (with foreground process)
# god -c path/to/background_monitor.god (with background process)
# http://godrb.com/ for more information