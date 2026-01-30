require "test_helper"

class LoginControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      email: "test@example.com",
      password: "password123"
    )
  end

  test "should login with correct credentials" do
    post "/api/login", params: {
      email: "test@example.com",
      password: "password123"
    }

    assert_response :success
    assert_match "signed in", response.body
    assert_match "token", response.body
  end

  test "should not login with incorrect password" do
    post "/api/login", params: {
      email: "test@example.com",
      password: "wrongpassword"
    }

    assert_response :success
    assert_match "try another email address or password", response.body
  end

  test "should not login with non-existent email" do
    post "/api/login", params: {
      email: "nonexistent@example.com",
      password: "password123"
    }

    assert_response :success
    assert_match "try another email address or password", response.body
  end

  test "should return json response" do
    post "/api/login", params: {
      email: "test@example.com",
      password: "password123"
    }

    assert_match "application/json", response.content_type
  end
end
