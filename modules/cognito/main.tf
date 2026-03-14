# 1. User Pool for Logged-in Users
resource "aws_cognito_user_pool" "pool" {
  name = "${var.env}-user-pool"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length = 8
  }
}

# 2. App Client for the Frontend
resource "aws_cognito_user_pool_client" "client" {
  name         = "${var.env}-app-client"
  user_pool_id = aws_cognito_user_pool.pool.id
  explicit_auth_flows = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH"]
}

# 3. Identity Pool for Guest Access
resource "aws_cognito_identity_pool" "identity_pool" {
  identity_pool_name               = "${var.env} identity pool"
  allow_unauthenticated_identities = true # CRITICAL for Guest Persistence

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.client.id
    provider_name           = aws_cognito_user_pool.pool.endpoint
    server_side_token_check = false
  }
}