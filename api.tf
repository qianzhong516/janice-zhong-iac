resource "aws_apigatewayv2_api" "visits" {
  name          = "visits-http-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["http://localhost:3000", "https://janice-zhong.com"]
    allow_methods = ["GET", "PUT"]
    allow_headers = ["content-type", "authorization"]
    max_age       = 3600
  }
}

// Custom domain
resource "aws_apigatewayv2_domain_name" "api" {
  domain_name = "api.${local.full_domain}"

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.syd_cert.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

// Stage
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.visits.id
  name        = "default"
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = 50
    throttling_rate_limit  = 200
  }
}

// Mapping a base path of your custom domain name to a stage of an API
resource "aws_apigatewayv2_api_mapping" "api_mapping" {
  api_id      = aws_apigatewayv2_api.visits.id
  domain_name = aws_apigatewayv2_domain_name.api.id
  stage       = aws_apigatewayv2_stage.default.id
}

resource "aws_apigatewayv2_integration" "increment_visits_integration" {
  api_id           = aws_apigatewayv2_api.visits.id
  integration_type = "AWS_PROXY"

  integration_method = "POST"
  integration_uri    = aws_lambda_function.increment_visits.arn
}

resource "aws_apigatewayv2_route" "increment_visits_route" {
  api_id    = aws_apigatewayv2_api.visits.id
  route_key = "PUT /visits"

  target = "integrations/${aws_apigatewayv2_integration.increment_visits_integration.id}"
}

resource "aws_apigatewayv2_integration" "get_visits_integration" {
  api_id           = aws_apigatewayv2_api.visits.id
  integration_type = "AWS_PROXY"

  integration_method = "POST"
  integration_uri    = aws_lambda_function.get_visits.arn
}

resource "aws_apigatewayv2_route" "get_visits_route" {
  api_id    = aws_apigatewayv2_api.visits.id
  route_key = "GET /visits"

  target = "integrations/${aws_apigatewayv2_integration.get_visits_integration.id}"
}