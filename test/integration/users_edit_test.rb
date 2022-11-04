require "test_helper"

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "should fail to edit a user" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template('users/edit')
    patch(user_path(@user), { params: {
      user: {
        name: "",
        email: "example@test",
        password: "password",
        password_confirmation: "passw0rd"
      }
    }})
    assert_template('users/edit')
  end

  test "should complete to edit" do
    # 編集できるようにログイン状態にしておく
    log_in_as(@user)
    # 編集画面を開く
    get(edit_user_path(@user))
    assert_template('users/edit')
    # 更新できるユーザの名前、メアドで更新リクエスト
    name = "Teferi Akosa"
    email = "teferi@railstutorial.org"
    patch(user_path(@user), { params: {
      user: {
        name: name,
        email: email,
        password: "", # パスワードは更新しない
        password_confirmation: ""
      }
    }})
    # メッセージを出してリダイレクトさせる
    assert(flash.present?)
    assert_redirected_to(@user)
    # DBから最新のユーザ情報を読み出してメモリ上のオブジェクトを更新
    @user.reload
    assert_equal(name, @user.name)
    assert_equal(email, @user.email)
  end

  test "should success to edit with friendly forwarding" do
    # 未ログイン状態から保護されたページに移動、ログインしたらそのまま編集できる
    get(edit_user_path(@user))
    log_in_as(@user)
    assert_redirected_to(edit_user_url(@user))
    name = "Teferi Akos"
    email = "test@example.com"
    patch(user_path(@user), { params: {
      user: {
        name: name,
        email: email,
        password: "", # パスワードは更新しない
        password_confirmation: ""
      }
    }})
    # メッセージを出してリダイレクトさせる
    assert(flash.present?)
    assert_redirected_to(@user)
    # DBから最新のユーザ情報を読み出してメモリ上のオブジェクトを更新
    @user.reload
    assert_equal(name, @user.name)
    assert_equal(email, @user.email)
  end
end
