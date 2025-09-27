Create the role and attach the basic logging policy:

aws iam create-role \
  --role-name lambda-hello-role \
  --assume-role-policy-document file://trust.json

aws iam attach-role-policy \
  --role-name lambda-hello-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole


package zip:

zip function.zip lambda_function.py


Create the Lambda

ROLE_ARN=$(aws iam get-role --role-name lambda-hello-role --query 'Role.Arn' --output text)

aws lambda create-function \
  --function-name hello-lambda \
  --runtime python3.12 \
  --role "$ROLE_ARN" \
  --handler lambda_function.handler \
  --zip-file fileb://function.zip \
  --architectures arm64 
  // arm64 is cheaper, use x86_64 if you rely on native x86 libs


Invoke & test

aws lambda invoke \
  --function-name hello-lambda \
  --payload '{"name":"Sandip"}' \
  --cli-binary-format raw-in-base64-out \
  response.json

cat response.json



see logs:

aws logs tail /aws/lambda/hello-lambda --follow

Expose over HTTPS quickly (Function URL)


aws lambda create-function-url-config \
  --function-name hello-lambda \
  --auth-type NONE

aws lambda add-permission \
  --function-name hello-lambda \
  --action lambda:InvokeFunctionUrl \
  --statement-id url-public \
  --principal '*' \
  --function-url-auth-type NONE

  test:
  curl "<FUNCTION_URL>" -d '{"name":"Learner"}' -H "Content-Type: application/json


  Clean up:
  aws lambda delete-function --function-name hello-lambda
aws iam detach-role-policy --role-name lambda-hello-role --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
aws iam delete-role --role-name lambda-hello-role




aws apigatewayv2 delete-api --api-id "$API_ID" --region "$REGION"
# simple-lambda-project
