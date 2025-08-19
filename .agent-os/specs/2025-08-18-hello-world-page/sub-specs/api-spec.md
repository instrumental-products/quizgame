# API Specification

This is the API specification for the spec detailed in @.agent-os/specs/2025-08-18-hello-world-page/spec.md

## Endpoints

### GET /

**Purpose:** Display hello world page for logged-in users
**Parameters:** None
**Response:** HTML page with hello world message
**Errors:** Redirects to login if user not authenticated

### POST /login

**Purpose:** Authenticate user and create session
**Parameters:** email, password
**Response:** Redirect to root path on success, render login form with errors on failure
**Errors:** Invalid credentials, missing parameters

### DELETE /logout

**Purpose:** Destroy user session and log out
**Parameters:** None
**Response:** Redirect to login page
**Errors:** None

## Controllers

### HomeController
- **index action:** Renders hello world page for authenticated users
- **before_action:** Requires user authentication
- **error handling:** Redirects to login if not authenticated

### SessionsController
- **new action:** Display login form
- **create action:** Authenticate user and create session
- **destroy action:** Log out user and destroy session
- **error handling:** Flash messages for authentication failures