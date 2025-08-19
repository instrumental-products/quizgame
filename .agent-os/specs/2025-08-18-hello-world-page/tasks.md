# Spec Tasks

## Tasks

- [x] 1. Set up authentication system
  - [x] 1.1 Write tests for User authentication (login/logout)
  - [x] 1.2 Add bcrypt gem to Gemfile and bundle install
  - [x] 1.3 Add password_digest column to users table via migration
  - [x] 1.4 Update User model with has_secure_password
  - [x] 1.5 Create SessionsController with new, create, and destroy actions
  - [x] 1.6 Implement authentication helper methods in ApplicationController
  - [x] 1.7 Verify all authentication tests pass

- [x] 2. Create login interface
  - [x] 2.1 Write tests for login form rendering and submission
  - [x] 2.2 Create login form view (sessions/new.html.erb)
  - [x] 2.3 Style login form with Tailwind CSS
  - [x] 2.4 Add flash message support for login errors
  - [x] 2.5 Configure routes for login/logout paths
  - [x] 2.6 Verify all login interface tests pass

- [x] 3. Build hello world landing page
  - [x] 3.1 Write tests for HomeController and authentication requirement
  - [x] 3.2 Create HomeController with index action
  - [x] 3.3 Add before_action filter to require authentication
  - [x] 3.4 Create home/index.html.erb view with "Hello World" message
  - [x] 3.5 Style the hello world page with Tailwind CSS
  - [x] 3.6 Set root route to home#index
  - [x] 3.7 Verify all hello world page tests pass

- [x] 4. Integration and polish
  - [x] 4.1 Write integration tests for complete login flow
  - [x] 4.2 Test redirect behavior for unauthenticated users
  - [x] 4.3 Add logout functionality and link
  - [x] 4.4 Verify flash messages display correctly
  - [x] 4.5 Run full test suite and ensure all tests pass