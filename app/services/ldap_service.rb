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
          uidnumber: User.find_by_user_name(user_name).id.to_s+'1000',
          gidnumber: ORDINARY_USER_GROUP_ID,
          objectclass: ['top', 'posixAccount', 'inetOrgPerson']
      }
      open_ldap {|server| server.add(dn: user_dn(user_name), attributes: entry)}
    end

    def set_password(user_name, new_password)
      md5_password = Net::LDAP::Password.generate(:md5, new_password)
      open_ldap {|server| server.replace_attribute(user_dn(user_name), 'userpassword', md5_password)}
    end

    def attach_role(role_name, user_name)
      role_dn="cn=#{role_name},ou=groups,dc=worksap,dc=com"
      ops=[[:add, :memberuid, user_name]]
      open_ldap {|server| server.modify dn: role_dn, operations: ops}
    end

    def find_user(user_name)
      filter = Net::LDAP::Filter.eq("cn", user_name)
      open_ldap {|server| return server.search(base: 'ou=users,dc=worksap,dc=com', filter: filter)}
    end

    private
    def open_ldap
      Net::LDAP.new(CONNECTION_CONFIG).open do |server|
        loop_time = 0
        begin
          yield server
          raise server.get_operation_result['message'] unless server.get_operation_result['code'] == 0
        rescue => error
          loop_time += 1
          retry if loop_time < 9
          Rails.logger.error "Failed to execute LDAP service: #{error}"
        end
      end
    end

    def user_dn(user_name)
      "cn=#{user_name}," + Rails.configuration.ldap['user_base_dn']
    end
  end
end
