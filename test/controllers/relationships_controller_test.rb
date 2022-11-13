require "test_helper"

class RelationshipsControllerTest < ActionDispatch::IntegrationTest
  test "require login to create active relationships" do
    assert_no_difference 'Relationship.count' do
      post(relationships_path)
    end
    assert_redirected_to(login_url)
  end

  test "require login to delete active relationships" do
    assert_no_difference 'Relationship.count' do
      post(relationships_path)
    end
    assert_redirected_to(login_url)
  end
end
