require 'resque'

require 'resqued/backoff'

module Resqued
  # Models a worker process.
  class Worker
    def initialize(options)
      @queues = options.fetch(:queues)
      @backoff = Backoff.new
    end

    # Public: The pid of the worker process.
    attr_reader :pid

    # Private.
    attr_reader :queues

    # Public: True if there is no worker process mapped to this object.
    def idle?
      pid.nil?
    end

    # Public: Checks if this worker works on jobs from the queue.
    def queue_key
      queues.sort.join(';')
    end

    # Public: Claim this worker for another listener's worker.
    def wait_for(pid)
      raise "Already running #{@pid} (can't wait for #{pid})" if @pid
      @self_started = nil
      @pid = pid
    end

    # Public: The old worker process finished!
    def finished!(process_status)
      @pid = nil
      @backoff.finished
    end

    # Public: The amount of time we need to wait before starting a new worker.
    def backing_off_for
      @pid ? nil : @backoff.how_long?
    end

    # Public: Start a job, if there's one waiting in one of my queues.
    def try_start
      return if @backoff.wait?
      @backoff.started
      @self_started = true
      @pid = fork do
        $0 = "STARTING RESQUE FOR #{queues.join(',')}"
        ENV['QUEUES'] = queues.join(',')
        ENV['TERM_CHILD'] = 'y'
        ENV['RESQUE_TERM_TIMEOUT'] ||= '999999999'
        exec "bundle exec rake resque:work"
      end
    end

    # Public: Shut this worker down.
    def kill(signal)
      signal = signal.to_s
      # Use the new resque worker signals.
      signal = 'INT' if signal == 'TERM'
      signal = 'TERM' if signal == 'QUIT'
      Process.kill(signal, pid) if pid && @self_started
    end
  end
end
