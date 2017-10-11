class CommonUtils
  class << self
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

    def valid_sign?(*info, got_sign)
      return false unless got_sign
      expected = Digest::MD5::hexdigest(info.join('-'))
      return true if expected == got_sign.to_s
      puts 'Sign Validation for:  ' + info.join(' - ')
      puts 'Expected: ' + expected
      puts 'GOT:      ' + got_sign
      false

    end

    def email_token(act, user)
      aes_encrypt(user.credential[0...16], "#{Time.now.to_i}-#{act.to_s}")
    end

    def valid_email_token?(act, token, user)
      msg = aes_decrypt(user.credential[0...16], token).split('-')
      return false if msg.size!= 2 || msg.any?(&:nil?)
      msg[1] == act && !email_link_expired?(msg[0])
    end

    def email_link_expired?(issue_time)
      issue_time.to_i > Time.now.to_i || issue_time.to_i < 3000.minutes.ago.to_i
    end
  end
end