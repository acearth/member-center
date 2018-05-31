require 'net/ldap'
require 'active_support'

class ITS
  HOST = 'ldap-jp01.workslan'

  USER_DN = 'ou=ldap_users,dc=internal,dc=worksap,dc=com'

  class << self
    def authenticate(user, password)
      Net::LDAP.new(host: HOST).open do |server|
        server.auth("uid=#{user},ou=ldap_users,dc=internal,dc=worksap,dc=com", password)
        if server.bind
          puts "SUCC #{user}"
        else
          puts "FAILED #{user}"
        end
      end
    end

    def fetch_user(user)
      Net::LDAP.new(host: HOST).open do |server|
        filter = Net::LDAP::Filter.eq("uid", user)
        result = server.search(base: USER_DN, filter: filter)
        if server.get_operation_result['code'] == 0
          return result.first
          # info = user_entry(:title, :displayname, :employeenumber, :jpegphoto)
          # puts user_entry.inspect
          # puts user_entry[:description]
          # puts user_entry[:displayname]
          # else
          #   puts 'no'
        end
      end
    end
  end
end

# ITS.fetch_user('an_x')
# ITS.fetch_user('1347')

count = 0
# nou.each do |em|
#   u = ITS.fetch_user(em)
#   if u
#     puts u.inspect
#   else
#     (count += 1; puts "#{count}  #{em}")
#   end
# end


# ITS.authenticate('zheng_c', '')
# a = ITS.fetch_user('an_x')
# puts a.inspect
# puts ITS.fetch_user('zheng_c').inspect
