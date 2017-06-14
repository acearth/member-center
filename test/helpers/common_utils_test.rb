require 'test_helper'

class CommonUtilsTest < ActionDispatch::IntegrationTest

  test "encrypt_and_decrypt" do
    key = '1234567812345678'
    text = 'Text for encryption'
    assert_equal text, CommonUtils.aes_decrypt(key, CommonUtils.aes_encrypt(key, text))
  end
end