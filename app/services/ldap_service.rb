class LdapService
  ORDINARY_USER_GROUP_ID = '500'
  CONNECTION_CONFIG = {
      auth: {
          method: :simple,
          username: ENV['LDAP_ADMIN_DN'],
          password: ENV['LDAP_ADMIN_PASSWORD']
      },
      host: ENV['LDAP_HOST'],
      port: ENV['LDAP_PORT'] || '389'
  }

  class << self
    def find_lost_user
      User.all.reject {|user| user.ldap_stored?}
    end

    def add_email_entry(email, password)
      email_prefix = email.split("@").first
      entry = {
          uid: email,
          userpassword: Net::LDAP::Password.generate(:md5, password),
          cn: email,
          sn: email,
          mail: email,
          homedirectory: email_prefix,
          uidnumber: "#{Time.now.to_i * 100}",
          gidnumber: ORDINARY_USER_GROUP_ID,
          objectclass: ['top', 'posixAccount', 'inetOrgPerson']
      }
      open_ldap {|server| server.add(dn: user_dn(email), attributes: entry)}
    end

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

    def find_by_uid(uid)
      filter = Net::LDAP::Filter.eq("uid", uid)
      open_ldap {|server| return server.search(base: 'ou=users,dc=worksap,dc=com', filter: filter)}
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
      "cn=#{user_name}," + ENV['LDAP_USER_BASE_DN']
    end
  end
end
