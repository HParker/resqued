def main
  r,w = IO.pipe
  if fork
    trap(:CHLD) { wait_for_child('signal') ; exit }
    p [:parent, $$]
    w.close
    reader(r)
    wait_for_child('natural')
  else
    p [:child, $$]
    #r.close
    exec 'ruby', $0, 'child', r.to_i.to_s
    writer(w)
  end
end

def wait_for_child(reason)
  res = Process.waitpid2
  p [$$, reason, res]
end

def writer(w)
  w.puts "#$$ I AM THE WRITER"
  w.close
end

def reader(r)
  puts "#$$ reads: #{r.readline}"
end

if ARGV[0] == 'child'
  fd = ARGV[1].to_i - 1
  p [fd, f = IO.for_fd(ARGV[1].to_i, 'w')]
  puts "I AM FAKE"
  writer(f)
else
  main
end
