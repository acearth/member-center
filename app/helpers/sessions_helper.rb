module SessionsHelper
  RSA_KEY = OpenSSL::PKey::RSA.new File.read ('config/jwt_key.pem')

  # Logs in the given user.
  def log_in(user)
    session[:user_id] = user.id
  end

  def its_user(ldap_entry, remember_me)
    jwt_payload = {
        display_name: ldap_entry[:displayname].first,
        title: ldap_entry[:title].first,
        email: ldap_entry[:mail].first,
        emp_id: ldap_entry[:employeenumber].first,
        organization: ldap_entry[:o].first,
        iat: Time.now.to_i
    }
    token = JWT.encode jwt_payload, Rails.application.credentials.secret_key_base, 'HS256'
    cookies[:ldap_jwt] = {
        value: token,
        expires: remember_me ? 1.month.from_now : 1.day.from_now
    }
    # TODO-confirm: set Genius JWT only when the user already registered
    genius = User.find_by_email(jwt_payload[:email])
    user = User.new(display_name: jwt_payload[:display_name],
                    user_name: jwt_payload[:display_name],
                    emp_id: jwt_payload[:emp_id],
                    role: genius && genius.role || :ordinary,
                    email: jwt_payload[:email])
      guarantee_jwt(user)
      jwt_rsa(user)
  end

  # Remembers a user in a persistent session.
  def remember(user)
    user.remember
    cookies[:user_id] = {
        expires: 1.month.from_now,
        value: user.id
    }
    cookies[:remember_token] = {
        expires: 1.month.from_now,
        value: user.remember_token
    }
    guarantee_jwt(user)
    jwt_rsa(user)
  end

  # Returns true if the given user is the current user.
  # TODO: current user?
  def current_user?(user)
    user == current_user
  end

  # Returns the current logged-in user (if any).
  def current_user
    if ldap_jwt_valid?
      user_info = (JWT.decode cookies[:ldap_jwt], Rails.application.credentials.secret_key_base, true, {algorithm: 'HS256'}).first
      @current_user = User.new(email: user_info['email'], emp_id: user_info['emp_id'], display_name: user_info['display_name'])
    else
      if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
      elsif (user_id = cookies.signed[:user_id])
        user = User.find_by(id: user_id)
        if user && user.authenticated?(cookies[:remember_token])
          log_in user
          @current_user = user
        end
      end
      @current_user && guarantee_jwt(@current_user) && jwt_rsa(@current_user)
      @current_user
    end
  end

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end

  def is_admin?
    current_user && current_user.role.to_s == 'admin'
  end


  # Forgets a persistent session.
  def forget(user)
    user.forget if user.id # ONLY works for Genius account
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
    cookies.delete(:ldap_jwt)
    revoke_jwt
  end


  # Logs out the current user.
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  # Redirects to stored location (or to the default).
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # Stores the URL trying to be accessed.
  def store_location
    #TODO-check
    session[:forwarding_url] = request.url if request.get?
  end

  def jwt_rsa(user)
    payload = {
        display_name: user.display_name,
        emp_id: user.emp_id,
        user_name: user.user_name,
        email: user.email,
        role: user.role
    }
    jwt = JWT.encode payload, RSA_KEY, 'RS256'
    cookies[:genius] = {
        domain: '.internal.worksap.com',
        expires: 1.month.from_now,
        value: jwt
    }
  end

  def guarantee_jwt(user)
    payload = {
        display_name: user.display_name,
        emp_id: user.emp_id,
        user_name: user.user_name
    }
    token = JWT.encode payload, ENV['JWT_SECRET'], 'HS256'
    cookies[:jwt_genius] = {
        domain: '.internal.worksap.com',
        expires: 1.month.from_now,
        value: token
    }
  end

  def revoke_jwt
    cookies.delete(:jwt_genius, domain: '.internal.worksap.com')
    cookies.delete(:genius, domain: '.internal.worksap.com')
    cookies.delete(:ldap_jwt) #TODO-check: domain
  end

  def ldap_jwt_valid?
    JWT.decode cookies[:ldap_jwt], Rails.application.credentials.secret_key_base, true, {algorithm: 'HS256'}
    true
  rescue
    false
  end
end
