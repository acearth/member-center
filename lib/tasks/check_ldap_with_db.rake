namespace :ldap do
  task :user_check => :environment do
    blank_users = LdapService.find_lost_user
    puts "This job needs to check Database and LDAP server, requires long time maybe."
    puts "You can exit by CTRL + C if you want to stop"
    if blank_users.empty?
      puts "Congrats! Every user is synchronized to LDAP server"
    else
      puts "NOTICE: #{blank_users.size} users didn't stored into LDAP server. Please fix this problem manually."
      puts blank_users
    end
  end
end
