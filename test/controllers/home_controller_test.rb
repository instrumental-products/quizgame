require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
  end

  test "should redirect to login when not authenticated" do
    get root_path
    assert_redirected_to login_path
    assert_equal "Please login to continue", flash[:alert]
  end

  test "should get index when authenticated" do
    # Simulate login
    post login_path, params: { email: @user.email, password: "password123" }
    
    get root_path
    assert_response :success
    assert_select "h1", "Hello World"
  end

  test "should display user name when logged in" do
    post login_path, params: { email: @user.email, password: "password123" }
    
    get root_path
    assert_response :success
    assert_match @user.name, response.body
  end
end