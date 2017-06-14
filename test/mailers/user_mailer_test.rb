require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  fake_link = 'http://my.fake.host/fake_path'
  test "activate" do
    mail = UserMailer.activate(User.first, fake_link)
    assert_equal "Activate User | Genius Center", mail.subject
    assert_equal [User.first.email], mail.to
    assert_equal ["genius.worksap@gmail.com"], mail.from
    assert_includes mail.body.encoded, fake_link
  end

  test "password_reset" do
    mail = UserMailer.password_reset(User.first, fake_link)
    assert_equal "Password Reset | Genius Center", mail.subject
    assert_equal [User.first.email], mail.to
    assert_equal ["genius.worksap@gmail.com"], mail.from
    assert_includes mail.body.encoded, fake_link
  end

end
