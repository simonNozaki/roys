require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user_michael = users(:michael)
    @user_archer = users(:archer)
  end

  test "should get new" do
    get signup_path
    # レスポンスの中身は@responseで取り出せる。
    # p @response
    assert_response :success
  end

  test "should redirect to edit on not logged in" do
    get(edit_user_path(@user_michael))
    assert flash.present?
    assert_redirected_to login_url
  end

  test "should redirect to update on not logged in" do
    patch(user_path(@user_michael), { params: {
      name: @user_michael.name,
      email: @user_michael.email
    }})
    assert flash.present?
    assert_redirected_to login_url
  end

  test "should redirect edit on logged in as another user" do
    log_in_as(@user_archer)
    get(edit_user_path(@user_michael))
    assert(flash.empty?)
    assert_redirected_to(root_url)
  end

  test "should redirect update on logged in as another user" do
    log_in_as(@user_archer)
    patch(user_path(@user_michael), { params: {
      name: @user_michael.name,
      email: @user_michael.email
    }})
    assert(flash.empty?)
    assert_redirected_to(root_url)
  end
end
