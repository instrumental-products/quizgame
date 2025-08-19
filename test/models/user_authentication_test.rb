require "test_helper"

class UserAuthenticationTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      name: "Test User",
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  test "user should have secure password" do
    assert_respond_to @user, :password_digest
    assert_respond_to @user, :authenticate
  end

  test "user should be valid with valid attributes" do
    assert @user.valid?
  end

  test "user should require password" do
    @user.password = nil
    assert_not @user.valid?
    assert_includes @user.errors[:password], "can't be blank"
  end

  test "user should require password confirmation to match" do
    @user.password_confirmation = "different"
    assert_not @user.valid?
  end

  test "user should authenticate with correct password" do
    @user.save
    assert @user.authenticate("password123")
  end

  test "user should not authenticate with incorrect password" do
    @user.save
    assert_not @user.authenticate("wrongpassword")
  end

  test "password should have minimum length" do
    @user.password = @user.password_confirmation = "short"
    assert_not @user.valid?
    assert_includes @user.errors[:password], "is too short (minimum is 6 characters)"
  end
end