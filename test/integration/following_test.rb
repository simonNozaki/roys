require "test_helper"

class FollowingTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @user_archer = users(:archer)
    log_in_as(@user)
  end

  test "following page" do
    get(following_user_path(@user))
    assert(@user.following.present?)
    assert_match(@user.following.count.to_s, response.body)
    @user.following.each do |f|
      assert_select("a[href=?]", user_path(f))
    end
  end

  test "followers page" do
    get(followers_user_path(@user))
    assert(@user.followers.present?)
    assert_match(@user.followers.count.to_s, response.body)
    @user.followers.each do |f|
      assert_select("a[href=?]", user_path(f))
    end
  end

  test "should follow by standard" do
    assert_difference '@user.following.count', 1 do
      post(relationships_path, {
        params: {
          followed_id: @user_archer.id
        }
      })
    end
  end

  test "should follow by ajax" do
    assert_difference '@user.following.count', 1 do
      post(relationships_path, {
        xhr: true,
        params: {
          followed_id: @user_archer.id
        }
      })
    end
  end

  test "should unfollow by standard" do
    @user.follow(@user_archer)
    relationship = @user.active_relationships.find_by(followed_id: @user_archer.id)
    assert_difference '@user.following.count', -1 do
      delete(relationship_path(relationship))
    end
  end

  test "should unfollow by ajax" do
    @user.follow(@user_archer)
    relationship = @user.active_relationships.find_by(followed_id: @user_archer.id)
    assert_difference '@user.following.count', -1 do
      delete(relationship_path(relationship), { xhr: true })
    end
  end
end
