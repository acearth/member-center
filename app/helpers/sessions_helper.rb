module SessionsHelper
  RSA_KEY = OpenSSL::PKey::RSA.new File.read ('config/jwt_key.pem')

  # Logs in the given user.
  def log_in(user)
    session[:user_id] = user.id
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
  def current_user?(user)
    user == current_user
  end

  # Returns the current logged-in user (if any).
  def current_user
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

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end

  def is_admin?
    current_user && current_user.role.to_s == 'admin'
  end

  # Forgets a persistent session.
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
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
  end
end
