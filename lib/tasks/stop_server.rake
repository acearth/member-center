desc "Stop server if server started"
task :stop do
  pid_path = 'tmp/pids/server.pid'
  if File.exist?(pid_path)
    Process.kill(9, File.read(pid_path).to_i)
  else
    puts 'No running rails server'
  end
end