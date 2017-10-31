# This service used to add LDAP Support for
#   - adding user entry and
#   - setting user password.
# Requires the following environment variables:
#   - LDAP_ADMIN_DN
#   - LDAP_ADMIN_PASSWORD
#   - LDAP_SERVER_HOST
#   - LDAP_SERVER_PORT <optional>
#   - LDAP_USER_DN_BASE
#
class LdapService
  ORDINARY_USER_GROUP_ID = '500'
  CONNECTION_CONFIG = {
      auth: {
          method: :simple,
          username: ENV["LDAP_ADMIN_DN"],
          password: ENV["LDAP_ADMIN_PASSWORD"]
      },
      host: ENV["LDAP_SERVER_HOST"],
      port: ENV["LDAP_SERVER_PORT"] || '389'
  }

  class << self
    def add_user_entry(user_name, password, mail)
      entry = {
          uid: user_name,
          userpassword: Net::LDAP::Password.generate(:md5, password),
          cn: user_name,
          sn: user_name,
          mail: mail,
          homedirectory: user_name,
          uidnumber: User.find_by_user_name(user_name).id.to_s,
          gidnumber: ORDINARY_USER_GROUP_ID,
          objectclass: ['top', 'posixAccount', 'inetOrgPerson']
      }
      Net::LDAP.new(CONNECTION_CONFIG).open do |server|
        server.add(dn: dn(user_name), attributes: entry)
        unless server.get_operation_result['code'].to_i.zero?
          log_error("add_user_entry", user_name, server.get_operation_result)
        end
      end
    end

    def set_password(user_name, new_password)
      md5_password = Net::LDAP::Password.generate(:md5, new_password)
      Net::LDAP.new(CONNECTION_CONFIG).open do |server|
        server.replace_attribute(dn(user_name), 'userpassword', md5_password)
        unless server.get_operation_result['code'].to_i.zero?
          log_error("set_password", user_name, server.get_operation_result)
        end
      end
    end

    private
    def dn(user_name)
      "cn=#{user_name}," + ENV["LDAP_USER_DN_BASE"]
    end

    def log_error(method, user_name, error)
      Rails.logger.error "Failed to execute LDAP service:"+
                             " #{method} for user: #{user_name}," +
                             " code=#{error['code']}, message=#{error['message']},"+
                             " error_message= #{error['error_message']}"
    end
  end
end