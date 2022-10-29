require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test "full title helper" do
    assert_equal get_full_title, "Roys"
    assert_equal get_full_title("Help"), "Help | Roys"
  end
end
