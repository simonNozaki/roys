require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "activate_account" do
    user = users(:michael)
    user.activation_token = User.get_new_token
    mail = UserMailer.activate_account(user)
    assert_equal "Account activation", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["noreply@example.com"], mail.from
    assert_match user.name, mail.body.encoded
    assert_match user.activation_token, mail.body.encoded
    assert_match CGI.escape(user.email), mail.body.encoded
  end

  test "should send password reset" do
    user = users(:michael)
    user.reset_token = User.get_new_token
    mail = UserMailer.reset_password(user)
    assert_equal "Password reset", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["noreply@example.com"], mail.from
    assert_match(user.reset_token, mail.body.encoded)
    assert_match CGI.escape(user.email), mail.body.encoded
  end

end
