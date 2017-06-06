module CommonUtils
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
    return puts 'Cannot process HTTPS protocol: #{url} ' if url.include?('https')
    url = 'http://' + url unless url.start_with?('http://')
    url.include?('?') ? url : url + '?'
  end

  def signature(*params)
    puts '-------'
    puts params.join('-')
    puts '-------'
    p Digest::MD5::hexdigest(params.join('-'))
  end

  def valid_sign?(*params, got_sign)
    puts '==========='
    puts params.join('-')
    puts '==========='
    puts got_sign
    expected = Digest::MD5::hexdigest(params.join('-'))
    puts expected
    puts expected == got_sign.to_s
    puts '=-=-=-='
    expected == got_sign.to_s
  end
end