resource "aws_apigatewayv2_api" "this" {
  name          = "saprk-${var.project}-${var.environment}-apigw"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = [
      "http://localhost:5173",
      "http://ibe-demo-frontend-67984120.s3-website.ap-south-1.amazonaws.com"
    ]
    allow_methods = ["POST", "OPTIONS"]
    allow_headers = ["Content-Type", "X-API-Key"]
    allow_credentials = true
    max_age       = 300
  }
}

resource "aws_apigatewayv2_integration" "alb" {
  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "HTTP_PROXY"
  integration_uri        = "http://${var.alb_dns_name}/graphql"
  integration_method     = "POST"
  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_route" "graphql_post" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "POST /graphql"
  target    = "integrations/${aws_apigatewayv2_integration.alb.id}"
}

# resource "aws_apigatewayv2_route" "graphql_options" {
#   api_id    = aws_apigatewayv2_api.this.id
#   route_key = "OPTIONS /graphql"
#   target    = "integrations/${aws_apigatewayv2_integration.alb.id}"
# }

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "$default"
  auto_deploy = true
}