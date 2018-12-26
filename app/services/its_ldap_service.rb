require 'net/ldap'
require 'active_support'

##
#
# NOTE: ITS LDAP did NOT record IVTL users for now
# Using User.where('email like ?', "%@ivtl%") to see IVTL users
#
class ItsLdapService
  HOST = ENV['ITS_LDAP_HOST'] || 'ldap-jp01.workslan'
  PORT = ENV['ITS_LDAP_PORT'] || 389
  USER_DN = ENV['ITS_USER_DN'] || "ou=ldap_users,dc=internal,dc=worksap,dc=com"

  class << self

    def authenticate(email, password)
      Net::LDAP.new(host: HOST, port: PORT).open do |server|
        server.auth(dn_of(email), password)
        server.bind && true || false
      end
    end

    # @deprecated filter
    # filter = Net::LDAP::Filter.eq("uid", email_prefix)
    # result = server.search(base: USER_DN, filter: filter)
    def ldap_entry(email)
      Net::LDAP.new(host: HOST, port: PORT).open do |server|
        return server.search(base: dn_of(email)).first if server.get_operation_result['code'] == 0
        Rails.logger.error {"Failed to find ITS LDAP USER: #{email}, #{server.get_operation_result['code']}, #{server.get_operation_result['message']}"}
      end
    end

    def virtual_user(email)
      ldap_entry = ldap_entry(email)
      return User.new(user_name: "EMPTY LDAP RECORD, PLEASE CONTACT ADMIN") unless ldap_entry
      user_name = ldap_entry[:displayname].first || email.split('@').first
      display_name = ldap_entry[:displayname].first || email.split('@').first
      emp_id = ldap_entry[:employeenumber].first || 'not_given_by_ITS_authority'
      role = LdapService.role(email)
      User.new(user_name: user_name, emp_id: emp_id, email: email, display_name: display_name, role: role)
    end

    def dn_of(email)
      prefix, suffix = email.split("@")
      "uid=#{prefix},ou=#{suffix},#{USER_DN}"
    end
  end
end
