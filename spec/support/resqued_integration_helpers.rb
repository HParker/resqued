module ResquedIntegrationHelpers
  include ResquedPath

  def start_resqued(config: "", debug: false)
    # Don't configure any workers. That way, we don't need to have redis running.
    config_path = File.join(SPEC_TEMPDIR, "config.rb")
    File.write(config_path, config)

    @pid =
      if debug
        spawn resqued_path, config_path
      else
        logfile = File.join(SPEC_TEMPDIR, "resqued.log")
        File.write(logfile, "") # truncate it

        spawn resqued_path, "--logfile", logfile, config_path
      end
    sleep 1.0
  end

  def restart_resqued
    Process.kill(:HUP, @pid)
    sleep 1.0
  end

  def expect_running(listener:)
    processes = list_processes
    expect(processes).to include(is_resqued_master)
    listeners = processes.select { |p| p[:ppid] == @pid }.map { |p| p[:args] }
    expect(listeners).to all(match(/#{listener}/)).and(satisfy { |l| l.size == 1 })
  end

  def expect_not_running
    processes = list_processes
    expect(processes).not_to include(is_resqued_master)
  end

  def stop_resqued
    Process.kill(:TERM, @pid)
    sleep 1.0
  end

  def list_processes
    `ps axo pid,ppid,args`.lines.map { |line| pid, ppid, args = line.strip.split(/\s+/, 3); { pid: pid.to_i, ppid: ppid.to_i, args: args } }
  end

  def is_resqued_master
    satisfy { |p| p[:pid] == @pid && p[:args] =~ /resqued-/ }
  end
end
