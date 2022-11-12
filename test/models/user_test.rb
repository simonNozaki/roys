require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      name: "Example",
      email: "user@example.com",
      password: "passw0rd",
      password_confirmation: "passw0rd"
    )
  end

  test "should be true" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = "     "
    assert @user.invalid?
  end

  test "name should not be too long" do
    @user.name = "a" * 51
    assert @user.invalid?
  end

  test "email should be present" do
    @user.email = "     "
    assert @user.invalid?
  end

  test "email should not be too long" do
    @user.name = "#{"a" * 244}@example.com"
    assert @user.invalid?
  end

  test "email format should accept valid assresses" do
    valid_addresses = %w(
      user@example.com
      USER@foo.COM
      A_US-ER@foo.bar.org
      first.last@foo.jp
      alice+bob@bar.cn
    )

    valid_addresses.each { |address|
      @user.email = address
      assert @user.valid?, "#{address.inspect} should be valid"
    }
  end

  test "email format should reject valid assresses" do
    valid_addresses = %w(
      user@example,com
      user@example..com
      user_at_user.org
      user.name@example.
      foo@bar_baz.com
      foo@bar+baz.com
    )

    valid_addresses.each { |address|
      @user.email = address
      assert @user.invalid?, "#{address.inspect} should be invalid"
    }
  end

  test "email addresses should be unique" do
    duplicated = @user.dup
    # メアドは大文字小文字を区別しないため、大文字に揃えてアサーションに流す
    duplicated.email = @user.email.upcase
    @user.save
    assert duplicated.invalid?
  end

  test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "password should be present(nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert @user.invalid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert @user.invalid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?("")
  end

  test "should destroy associated microposts" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    michael = users(:michael)
    archer = users(:archer)
    assert_not(michael.following?(archer))
    michael.follow(archer)
    assert(michael.following?(archer))
    assert(archer.followers.include?(michael))
    michael.unfollow(archer)
    assert_not(michael.following?(archer))
  end
end
