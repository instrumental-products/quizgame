require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    # We'll update this fixture to have a password after adding the column
  end

  test "should get login page" do
    get login_path
    assert_response :success
    assert_select "h1", "Login"
  end

  test "should login with valid credentials" do
    post login_path, params: { email: @user.email, password: "password123" }
    assert_redirected_to root_path
    assert_equal @user.id, session[:user_id]
    assert_equal "Logged in successfully!", flash[:notice]
  end

  test "should not login with invalid credentials" do
    post login_path, params: { email: @user.email, password: "wrongpassword" }
    assert_response :unprocessable_entity
    assert_nil session[:user_id]
    assert_equal "Invalid email or password", flash.now[:alert]
  end

  test "should logout" do
    post login_path, params: { email: @user.email, password: "password123" }
    assert session[:user_id]
    
    delete logout_path
    assert_redirected_to login_path
    assert_nil session[:user_id]
    assert_equal "Logged out successfully!", flash[:notice]
  end

  test "should redirect to login if accessing protected page without authentication" do
    get root_path
    assert_redirected_to login_path
    assert_equal "Please login to continue", flash[:alert]
  end
end