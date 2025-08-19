require "test_helper"

class AuthenticationFlowTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
  end

  test "complete authentication flow" do
    # Visit root and get redirected to login
    get root_path
    assert_redirected_to login_path
    follow_redirect!
    assert_response :success
    assert_select "h1", "Login"
    
    # Login with valid credentials
    post login_path, params: { email: @user.email, password: "password123" }
    assert_redirected_to root_path
    follow_redirect!
    assert_response :success
    assert_select "h1", "Hello World"
    assert_match "Welcome, #{@user.name}!", response.body
    
    # Logout
    delete logout_path
    assert_redirected_to login_path
    follow_redirect!
    assert_response :success
    assert_select "h1", "Login"
    
    # Try to access root again - should redirect to login
    get root_path
    assert_redirected_to login_path
  end

  test "invalid login attempt" do
    get login_path
    assert_response :success
    
    post login_path, params: { email: @user.email, password: "wrongpassword" }
    assert_response :unprocessable_entity
    assert_select "h3", "Invalid email or password"
    
    # Should not be able to access protected pages
    get root_path
    assert_redirected_to login_path
  end

  test "flash messages display correctly" do
    # Login success message
    post login_path, params: { email: @user.email, password: "password123" }
    follow_redirect!
    assert_match "Logged in successfully!", response.body
    
    # Logout success message
    delete logout_path
    follow_redirect!
    assert_match "Logged out successfully!", response.body
    
    # Login required message
    get root_path
    follow_redirect!
    assert_match "Please login to continue", response.body
  end
end