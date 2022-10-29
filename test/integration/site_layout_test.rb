require "test_helper"

class SiteLayoutTest < ActionDispatch::IntegrationTest
  test "layout links" do
    # ルートに遷移
    get root_path
    # テンプレート内容およびhtml要素のアサーション
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path

    get contact_path
    assert_select "title", get_full_title("Contact")

    get signup_path
    assert_select "title", get_full_title("Sign up")
  end
end
