require "test_helper"

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    # fixtureを使ってテスト用ユーザを生成する
    @user = users(:michael)
  end

  test "login with invalid information" do
    get login_path
    assert_template 'sessions/new'

    post login_path, params: { session: { email: "", password: "" } }
    assert_template 'sessions/new'
    assert_not flash.empty?

    get root_path
    assert flash.empty?
  end

  test "login with valid information" do
    get login_path
    post(login_path, params: { session: { email: @user.email, password: "password"}})
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
  end

  test "login with valid email/invalid password" do
    get login_path
    assert_template 'sessions/new'

    post(login_path, params: { session: { email: @user.email, password: "invalid"}})
    assert_not is_logged_in?
    assert_template 'sessions/new'
    assert flash.present?

    get root_path
    assert flash.empty?
  end

  test "login with valid information followed by logout" do
    # 普通にログインできることを確認
    get login_path
    post(login_path, params: { session: { email: @user.email, password: "password"}})
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)

    # ログアウトおよびログイン前のレイアウトになっていることの確認
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url

    # 2番目のウィンドウでのログアウトをシミュレートする
    delete logout_path
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  test "login with remembering" do
    log_in_as(@user, remember_me: '1')
    assert_not_empty cookies[:remember_token]
  end

  test "login without remembering" do
    # cookieを使ってログイン
    log_in_as(@user, remember_me: '1')
    delete logout_path

    # cookieを使わずにログイン
    log_in_as(@user, remember_me: '0')
    assert_empty cookies[:remember_token]
  end
end
