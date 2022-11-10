require "test_helper"

class MicropostsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @micropost = microposts(:orange)
  end

  test "should redirect to 'create' on not logged in" do
    assert_no_difference 'Micropost.count' do
      post(microposts_path, { params: { micropost: { content: "Lorem ipsum" } } })
    end
    assert_redirected_to(login_url)
  end

  test "should redirect to 'destroy' on not logged in" do
    assert_no_difference 'Micropost.count' do
      delete(micropost_path(@micropost))
    end
    assert_redirected_to(login_url)
  end

  test "should redirect to destroy by not posted microposts" do
    user_michael = users(:michael)
    micropost_ants = microposts(:ants)
    log_in_as(user_michael)
    assert_no_difference 'Micropost.count' do
      delete(micropost_path(micropost_ants))
    end
    assert_redirected_to(root_url)
  end
end
