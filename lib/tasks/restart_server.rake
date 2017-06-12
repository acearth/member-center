desc "I am short, but comprehensive description for my cool task"
# NOTICE: run at 13000 port
task :restart do
    `cat tmp/pids/server.pid | xargs kill -9`
    `rails server -p 13000 -d`
end
