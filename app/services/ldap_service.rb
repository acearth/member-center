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

  ROLE = ['admin', 'cimaster', 'ordinary']

  GROUP_BASE_DN = 'ou=groups,dc=worksap,dc=com'

  class << self
    def role(user)
      attached_roles = []
      all_role.each do |role|
        role_filter = Net::LDAP::Filter.eq("cn", role)
        user_filter = Net::LDAP::Filter.contains("memberuid", user)
        filter = Net::LDAP::Filter.join(role_filter, user_filter)
        open_ldap do |server|
          if server.search(base: GROUP_BASE_DN, filter: filter).any?
            attached_roles << role
          end
        end
      end
      if attached_roles.size > 1
        return ["NOT ACCEPTED"]
      end
      attached_roles.first || 'ordinary'
    end

    def member_list(role)
      condition = Net::LDAP::Filter.eq("cn", role)
      open_ldap do |server|
        result = server.search(base: GROUP_BASE_DN, filter: condition).first
        return result ? result.memberuid : []
      end
    end

    def all_role
      condition = Net::LDAP::Filter.present("cn")
      open_ldap {|server| return server.search(base: GROUP_BASE_DN, attributes: 'cn', filter: condition).flat_map(&:cn)}
    end

    def set_role(role_name, user)
      open_ldap do |server|
        cn_pair(user).each do |cn|
          all_role.each {|role| server.modify dn: "cn=#{role},#{GROUP_BASE_DN}", operations: [[:delete, :memberuid, cn]]}
          server.modify dn: "cn=#{role_name},#{GROUP_BASE_DN}", operations: [[:add, :memberuid, cn]]
          sync_genius_role(cn, role_name)
          Rails.logger.info {"CI_LDAP: set role: #{cn}, #{role_name}"}
        end
      end
    end

    # Returns user_name and email address pair
    def cn_pair(cn)
      got = find_user(cn).first
      got.nil? ? [] : find_user(got.mail.first, 'mail').flat_map(&:cn)
    end

    def find_lost_user
      User.all.reject {|user| user.ldap_stored?}
    end

    def add_email_entry(email, password)
      old_user = cn_pair(email).first
      got_role = role(old_user) unless old_user.nil?
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
      set_role(got_role, email) if got_role && got_role != 'ordinary'
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

    #TODO-confirm
    def get_role(user_name)
      ROLE.each do |role|
        role_dn = "cn=#{role},ou=groups,dc=worksap,dc=com"
        filter = Net::LDAP::Filter.eq("uid", user_name)
        ops = [[:search, :memberuid, user_name]]
        open_ldap {|server| server.search base: role_dn, filter: filter}
      end
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

    def find_user(user_name, attr = 'cn')
      filter = Net::LDAP::Filter.eq(attr, user_name)
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
          Rails.logger.error "Failed to execute LDAP service: #{error}, #{error.backtrace}"
        end
      end
    end

    def user_dn(user_name)
      "cn=#{user_name}," + ENV['LDAP_USER_BASE_DN']
    end

    def sync_genius_role(cn, role)
      user = User.find_by_email(cn) || User.find_by_user_name(cn)
      user.role = role if user
      user.save
    end
  end
end
