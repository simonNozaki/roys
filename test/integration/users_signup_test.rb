require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: {
        user: {
          name: "",
          email: "user@invalid",
          password: "foo",
          password_confirmation: "bar"
        }
      }
    end
    assert_template 'users/new'
  end

  test "valid signup information with account activation" do
    get signup_path
    assert_difference 'User.count' do
      post users_path, params: {
        user: {
          name: "Rails tutorial",
          email: "example@railstutorial.org",
          password: "password",
          password_confirmation: "password"
        }
      }
    end
    # メールが送信される
    assert_equal(1, ActionMailer::Base.deliveries.size)
    user = assigns(:user)
    # ユーザはまだ有効ではない
    assert_not(user.activated?)
    # 有効化していない状態でログインする
    log_in_as(user)
    assert_not(is_logged_in?)
    # 有効化トークンが不正なログイン要求
    get(edit_account_activation_path("invalid token", email: user.email))
    assert_not(is_logged_in?)
    # 適切な有効化トークンの要求
    get(edit_account_activation_path(user.activation_token, email: user.email))
    assert(user.reload.activated)
    follow_redirect!
    assert_template 'users/show'
    assert_not flash.empty?
    assert is_logged_in?
  end
end
