# ----- setup -----
REGION=us-west-2
FUNC=hello-lambda
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
LAMBDA_ARN=$(aws lambda get-function --function-name "$FUNC" --query 'Configuration.FunctionArn' --output text)

# 1) Create empty HTTP API
API_ID=$(aws apigatewayv2 create-api \
  --name hello-http-api-explicit \
  --protocol-type HTTP \
  --region "$REGION" \
  --query 'ApiId' --output text)

# 2) Create Lambda proxy integration
INTEGRATION_ID=$(aws apigatewayv2 create-integration \
  --api-id "$API_ID" \
  --integration-type AWS_PROXY \
  --integration-uri "$LAMBDA_ARN" \
  --payload-format-version 2.0 \
  --integration-method POST \
  --region "$REGION" \
  --query 'IntegrationId' --output text)

# 3) Create a POST /hello route
aws apigatewayv2 create-route \
  --api-id "$API_ID" \
  --route-key "POST /hello" \
  --target "integrations/$INTEGRATION_ID" \
  --region "$REGION"

# 4) Create a stage (auto deploy)
aws apigatewayv2 create-stage \
  --api-id "$API_ID" \
  --stage-name prod \
  --auto-deploy \
  --region "$REGION"

# 5) Allow API Gateway to invoke Lambda (scope to this API/route)
aws lambda add-permission \
  --function-name "$FUNC" \
  --statement-id apigw-invoke-explicit \
  --action lambda:InvokeFunction \
  --principal apigateway.amazonaws.com \
  --source-arn arn:aws:execute-api:$REGION:$ACCOUNT_ID:$API_ID/*/POST/hello

# 6) Get the invoke URL and test
API_URL=$(aws apigatewayv2 get-apis --region "$REGION" \
  --query "Items[?ApiId=='$API_ID'].ApiEndpoint" --output text)

curl "$API_URL/prod/hello" \
  -H "Content-Type: application/json" \
  -d '{"name":"Sandip"}'
