require 'test_helper'

class SessionsHelperTest < ActionView::TestCase
  def setup
    @user = users(:michael)
    remember(@user)
  end

  test "get_current_user_or_nil returns a user when session is nil" do
    assert_equal(@user, get_current_user_or_nil)
    assert is_logged_in?
  end

  test "get_current_user_or_nil returns nil when remember digest is wrong" do
    @user.update_attribute(:remember_digest, User.digest(User.get_new_token))
    assert_nil get_current_user_or_nil
  end
end
