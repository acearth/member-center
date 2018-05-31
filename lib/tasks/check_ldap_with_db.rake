namespace :ldap do
  task :user_check => :environment do
    LdapService.find_lost_user
  end
end
