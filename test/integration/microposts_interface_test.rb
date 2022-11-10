require "test_helper"

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "microposts interface" do
    log_in_as(@user)
    get(root_path)
    assert_select('div.pagination')
    # 空のマイクロポスト、投稿できない
    assert_no_difference 'Micropost.count' do
      post(microposts_path, {
        params: {
          micropost: {
            content: ""
          }
        }
      })
    end
    assert_select('div#error_explanation')
    assert_select('a[href=?]', '/?page=2')
    # 登録できるマイクロポスト
    content = "This micropost really ties the room together"
    assert_difference('Micropost.count', +1) do
      post(microposts_path, {
        params: {
          micropost: {
            content: content
          }
        }
      })
    end
    assert_redirected_to(root_url)
    follow_redirect!
    assert_match(content, response.body)
    # 投稿を削除する
    assert_select('a', { text: 'delete' })
    first_post = @user.microposts.paginate({ page: 1 }).first
    assert_difference('Micropost.count', -1) do
      delete(micropost_path(first_post))
    end
    # 違うユーザのプロフィールを参照、削除の認可確認
    get(user_path(users(:archer)))
    assert_select('a', { text: 'delete', count: 0 })
  end

  test 'should get some microposts on profile' do
    log_in_as(@user)
    get(root_path)
    assert_match("#{@user.microposts.count} microposts", response.body)
    # 1つも投稿していないユーザでログイン、投稿
    user_malory = users(:malory)
    log_in_as(user_malory)
    get(root_path)
    assert_match("0 microposts", response.body)
    user_malory.microposts.create!({ content: "Hello, roys!" })
    get(root_path)
    assert_match("#{user_malory.microposts.count} micropost", response.body)
  end
end
