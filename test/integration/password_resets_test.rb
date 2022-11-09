require "test_helper"

class PasswordResetsTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  test "password resets" do
    get(new_password_reset_path)
    assert_template('password_resets/new')
    assert_select('input[name=?]', 'password_reset[email]')
    # 無効なメアドで再設定要求
    post(password_resets_path, { params: {
      password_reset: {
        email: ''
      }
    }})
    assert(flash.present?)
    assert_template('password_resets/new')
    # 存在するメアドで再設定要求、ホームに戻る
    post(password_resets_path, { params: {
      password_reset: {
        email: @user.email
      }
    }})
    assert_not_equal(@user.reset_digest, @user.reload.reset_digest)
    assert_equal(1, ActionMailer::Base.deliveries.size)
    assert(flash.present?)
    assert_redirected_to(root_url)
    user = assigns(:user)
    # 空のメアドで再設定リクエスト
    get(edit_password_reset_path(user.reset_token, email: ''))
    assert_redirected_to(root_url)
    # まだ有効ではない
    user.toggle!(:activated)
    get(edit_password_reset_path(user.reset_token, email: user.email))
    assert_redirected_to(root_url)
    user.toggle!(:activated)
    # 有効なメアドだが、トークンが無効
    get(edit_password_reset_path('invalid token', email: user.email))
    assert_redirected_to(root_url)
    # 有効な再設定リクエスト
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template('password_resets/edit')
    assert_select("input[name=email][type=hidden][value=?]", user.email)

    # パスワードおよびパスワード確認ともに無効
    patch(password_reset_path(user.reset_token), { params: {
      email: user.email,
      user: {
        password: 'foobaz',
        password_confirmation: 'barquux'
      }
    }})
    assert_select('div#error_explanation')
    # 空のパスワード
    patch(password_reset_path(user.reset_token), { params: {
      email: user.email,
      user: {
        password: '',
        password_confirmation: ''
      }
    }})
    assert_select('div#error_explanation')
    # 新しく設定したパスワードでログインできる
    patch(password_reset_path(user.reset_token), { params: {
      email: user.email,
      user: {
        password: 'password',
        password_confirmation: 'password'
      }
    }})
    # ログインできたらリセットダイジェストがnilに
    user.reload
    assert_nil(user.reset_digest)
    assert(is_logged_in?)
    assert(flash.present?)
    assert_redirected_to(user)
  end

  test "cannot reset password with expired token" do
    get(new_password_reset_path)
    post(password_resets_path, { params: {
      password_reset: {
        email: @user.email
      }
    }})
    @user = assigns(:user)
    # 期限を切らせる
    @user.update_attribute(:reset_sent_at, 3.hours.ago)
    patch(password_reset_path(@user.reset_token), { params: {
      email: @user.email,
      user: {
        password: "foobar",
        password_confirmation: "foobar"
      }
    }})
    assert_response(:redirect)
    follow_redirect!
    assert_match(/Password reset has expired./, response.body)
  end
end
