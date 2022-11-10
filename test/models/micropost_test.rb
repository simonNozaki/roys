require "test_helper"

class MicropostTest < ActiveSupport::TestCase
  def setup
    @user = users(:michael)
    @micropost = @user.microposts.build(content: "Lorem ipsum")
  end

  test "should satisfy constraint" do
    assert(@micropost.valid?)
  end

  test "should have user id in micropost object" do
    @micropost.user_id = nil
    assert(@micropost.invalid?)
  end

  test "content should be present" do
    @micropost.content = ""
    assert(@micropost.invalid?)
  end

  test "content should be under 140 chars" do
    @micropost.content = "a" * 141
    assert(@micropost.invalid?)
  end

  test "should be most recent first" do
    assert_equal(microposts(:most_recent), Micropost.first)
  end
end
