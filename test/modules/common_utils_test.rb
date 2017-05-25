require 'test_helper'

class CommonUtilsTest < ActionDispatch::IntegrationTest
  include CommonUtils

  test "encrypt_and_decrypt" do
    key = '1234567812345678'
    text = 'Text for encryption'
    assert_equal text, aes_decrypt(key, aes_encrypt(key, text))
  end
end