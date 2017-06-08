class ApplicationController < ActionController::Base
  include SessionsHelper
  # protect_from_forgery with: :exception
  before_action :set_locale
  protect_from_forgery

  # Confirms a logged-in user.
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end

  def set_locale
    cookies[:locale] = params[:locale] || cookies[:locale] || I18n.default_locale
    I18n.locale = cookies[:locale]
  end

  def aes_encrypt(key, text)
    cipher = OpenSSL::Cipher::AES.new(128, :CBC)
    cipher.encrypt
    cipher.key = key
    Base64.urlsafe_encode64(cipher.update(text) + cipher.final)
  end

  def aes_decrypt(key, data)
    decipher = OpenSSL::Cipher::AES.new(128, :CBC)
    decipher.decrypt
    decipher.key = key
    encrypted = Base64.urlsafe_decode64(data)
    "#{decipher.update(encrypted)}#{ decipher.final}"
  end

  def format_query(url, options = [])
    return puts "Cannot process HTTPS protocol: #{url} " if url.include?('https')
    url = 'http://' + url unless url.start_with?('http://')
    url.include?('?') ? url : url + '?'
  end

  def md5_sign(*info)
    Digest::MD5::hexdigest(info.join('-'))
  end

  def signature(*info)
    puts "USE md5_sign(...) instead"
    Digest::MD5::hexdigest(info.join('-'))
  end

  def valid_sign?(*info, got_sign)
    return false  unless got_sign
    expected = Digest::MD5::hexdigest(info.join('-'))
    return true if expected == got_sign.to_s
    puts 'Sign Validation for:  ' + info.join(' - ')
    puts 'Expected: ' + expected
    puts 'GOT:      ' + got_sign
    false
  end
end