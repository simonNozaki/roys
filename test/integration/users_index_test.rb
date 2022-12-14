require "test_helper"

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:michael)
    @non_admin = users(:archer)
  end

  test "should include user in page" do
    log_in_as(@admin)
    get(users_path)
    assert_template('users/index')
    assert_select('div.pagination')
    users_in_1st_page = get_active_paginated_users 1
    users_in_1st_page.each do |user|
      assert_select('a[href=?]', user_path(user), text: user.name)
    end
    assert_select('div.pagination', count: 2)
  end

  test("should be index as admin including pagination and delete links") do
    log_in_as(@admin)
    get(users_path)
    assert_template('users/index')
    assert_select('div.pagination', count: 2)
    users_in_1st_pages = get_active_paginated_users 1
    users_in_1st_pages.each do |user|
      assert_select('a[href=?]', user_path(user), text: user.name)
      unless user == @admin
        assert_select('a[href=?]', user_path(user), text: 'delete')
      end
    end
    assert_difference('User.count', -1) do
      delete(user_path(@non_admin))
    end
  end

  test("should be index as non-admin") do
    log_in_as(@non_admin)
    get(users_path)
    assert_select('a', text: 'delete', count: 0)
  end

  test "should have only activated users in index page" do
    log_in_as(@admin)
    get(users_path)
    assert_template('users/index')
    assert_select('div.pagination', count: 2)
    # indexページのもとになるインスタンス変数の参照
    page_users = assigns(:users)
    assert_empty(page_users.filter { |user| user.name == "Matthew Perry" })
    assert_not_empty(page_users.filter { |user| user.name == @admin.name })
  end

  private
    # 有効な、ページネーションされたユーザのリレーションを返す
    # @param [Integer] page_size
    # @return [ActiveRecord::Relation]
    def get_active_paginated_users(page_size)
      User
        .paginate(page: page_size)
        .filter { |user| user.activated == true }
    end
end
