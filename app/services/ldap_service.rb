# This service used to add LDAP Support for
#   - adding user entry and
#   - setting user password.
#
class LdapService
  ORDINARY_USER_GROUP_ID = '500'
  CONNECTION_CONFIG = {
      auth: {
          method: :simple,
          username: Rails.configuration.ldap['admin_dn'],
          password: Rails.configuration.ldap['admin_password']
      },
      host: Rails.configuration.ldap['host'],
      port: Rails.configuration.ldap['port'] || '389'
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


    def find_user(user_name)
      filter = Net::LDAP::Filter.eq("cn", user_name)
      Net::LDAP.new(CONNECTION_CONFIG).open do |server|
        return server.search(base: 'ou=users,dc=worksap,dc=com', filter: filter)
      end
    end

    def attach_role(role_name, user_name)
      role_dn="cn=#{role_name},ou=groups,dc=worksap,dc=com"
      ops=[[:add, :memberuid, user_name]]
      Net::LDAP.new(CONNECTION_CONFIG).open do |server|
        server.modify dn: role_dn, :operations => ops
      end
    end

    private
    def dn(user_name)
      "cn=#{user_name}," + Rails.configuration.ldap['user_base_dn']
    end

    def log_error(method, user_name, error)
      Rails.logger.error "Failed to execute LDAP service:" +
                             " #{method} for user: #{user_name}," +
                             " code=#{error['code']}, message=#{error['message']}," +
                             " error_message= #{error['error_message']}"
    end
  end
end
