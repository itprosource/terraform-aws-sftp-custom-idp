# API
resource "aws_api_gateway_rest_api" "api" {
  name = "custom-idp"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Resources
resource "aws_api_gateway_resource" "servers" {
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
  path_part = "servers"
}

resource "aws_api_gateway_resource" "server_id" {
  parent_id   = aws_api_gateway_resource.servers.id
  rest_api_id = aws_api_gateway_rest_api.api.id
  path_part = "{serverId}"
}

resource "aws_api_gateway_resource" "users" {
  parent_id   = aws_api_gateway_resource.server_id.id
  rest_api_id = aws_api_gateway_rest_api.api.id
  path_part = "users"
}

resource "aws_api_gateway_resource" "username" {
  parent_id   = aws_api_gateway_resource.users.id
  rest_api_id = aws_api_gateway_rest_api.api.id
  path_part = "{username}"
}

resource "aws_api_gateway_resource" "config" {
  parent_id   = aws_api_gateway_resource.username.id
  rest_api_id = aws_api_gateway_rest_api.api.id
  path_part = "config"
}

# Method
resource "aws_api_gateway_method" "get" {
  authorization = "AWS_IAM"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.config.id
  rest_api_id   = aws_api_gateway_rest_api.api.id

  request_parameters = {
    "method.request.querystring.protocol"= false,
    "method.request.querystring.sourceIp"= false,
    "method.request.header.Password"= false
  }
}

resource "aws_api_gateway_method_settings" "custom_identity_provider" {
  method_path = "*/*"
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.custom_idp.stage_name

  settings {
    data_trace_enabled = false
    #logging_level      = "INFO"
  }
}

resource "aws_api_gateway_integration" "example" {
  http_method = aws_api_gateway_method.get.http_method
  resource_id = aws_api_gateway_resource.config.id
  rest_api_id = aws_api_gateway_rest_api.api.id
  integration_http_method = "POST"
  type        = "AWS"
  uri = aws_lambda_function.lambda.invoke_arn

  request_templates = {
    "application/json" = <<EOF
{
  "username": "$input.params('username')",
  "password": "$util.escapeJavaScript($input.params('Password')).replaceAll("\\'","'")",
  "serverId": "$input.params('serverId')"
}
EOF
  }
}

resource "aws_api_gateway_integration_response" "integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.config.id
  http_method = aws_api_gateway_method.get.http_method
  status_code = aws_api_gateway_method_response.response.status_code

  response_templates = {
    "application/json" = ""
  }

  depends_on = [aws_api_gateway_integration.example]
}

resource "aws_api_gateway_method_response" "response" {
  http_method = aws_api_gateway_method.get.http_method
  resource_id = aws_api_gateway_resource.config.id
  rest_api_id = aws_api_gateway_rest_api.api.id
  status_code = "200"

  response_models = {"application/json" = aws_api_gateway_model.status_200.name}
}

resource "aws_api_gateway_model" "status_200" {
  content_type = "application/json"
  name         = "UserConfigResponseModel"
  rest_api_id  = aws_api_gateway_rest_api.api.id

  schema = <<EOF
{"$schema":"http://json-schema.org/draft-04/schema#","title":"UserUserConfig","type":"object","properties":{"Role":{"type":"string"},"Policy":{"type":"string"},"HomeDirectory":{"type":"string"},"PublicKeys":{"type":"array","items":{"type":"string"}}}}
EOF
}

resource "aws_api_gateway_deployment" "prod" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  depends_on = [aws_api_gateway_integration.example]
}

resource "aws_api_gateway_stage" "custom_idp" {
  deployment_id = aws_api_gateway_deployment.prod.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "prod"
}

resource "aws_iam_role" "transfer_role" {
  name = "transfer_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "transfer.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "TransferCanInvokeThisApi"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          "Action": [
            "execute-api:Invoke"
          ],
          "Resource": "${aws_api_gateway_rest_api.api.execution_arn}"
          #"Resource": "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.id}:${aws_api_gateway_rest_api.api.id}/prod/GET/*",
          "Effect": "Allow"
        },
      ]
    })
  }

  inline_policy {
    name   = "TransferCanReadThisApi"
    policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": [
            "apigateway:GET"
          ],
          "Resource": "*",
          "Effect": "Allow"
        }
      ]
    })
  }

}

resource "aws_lambda_permission" "api_gateway_trigger" {
  statement_id  = "apiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*"
}

#Cloudwatch
resource "aws_api_gateway_account" "custom_dip" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
}

resource "aws_iam_role" "cloudwatch" {
  name = "api_gateway_cloudwatch_global"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch" {
  name = "custom_idp_cw"
  role = aws_iam_role.cloudwatch.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}