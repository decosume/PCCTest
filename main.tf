provider "aws" {
  region =var.aws_region
}

# Adding S3 buckets for tickets and transactions
resource "aws_s3_bucket" "tfer--pccdailytransactionreport" {
  bucket        = var.bucket_name_transactions
  acl           = "private"

  versioning {
    enabled    = "true"
 }
}

resource "aws_s3_bucket" "tfer--pccdatafeed" {
  bucket        = var.bucket_name_tickets
  acl           = "private"

  versioning {
    enabled    = "true"
  }
}

# Adding Lambda function for transactions
resource "aws_lambda_function" "tfer--pcc_dailytransactionFn" {
  architectures = ["x86_64"]

  ephemeral_storage {
    size = "1024"
  }

  function_name                  = var.transactions_name_function
  handler                        = "lambda_function.lambda_handler"
  memory_size                    = "512"
  package_type                   = "Zip"
  reserved_concurrent_executions = "-1"
  role                           = "arn:aws:iam::439712476071:role/service-role/pcc_dailytransactionFn-role-v0fpf6ka"
  runtime                        = "python3.9"
  source_code_hash               = "9HQJd9/HuwpLTELojtyUKy+BFksKi7crG6uN8KD4PB4="
  timeout                        = "300"
  filename                       = "pcc_dailytransactionFn.zip"

  tracing_config {
    mode = "PassThrough"
  }
}

# Adding Lambda function for tickets
resource "aws_lambda_function" "tfer--pcc_loadticketsFn" {
  architectures = ["x86_64"]

  ephemeral_storage {
    size = "1024"
  }

  function_name                  = var.tickets_name_function
  handler                        = "lambda_function.lambda_handler"
  memory_size                    = "256"
  package_type                   = "Zip"
  reserved_concurrent_executions = "-1"
  role                           = "arn:aws:iam::439712476071:role/service-role/pcc_loadticketsFn-role-br00tq6v"
  runtime                        = "python3.9"
  source_code_hash               = "EIJpgfnfG0LlyzuO3os70seSv5pxRZJ1XluReHfQnC0="
  timeout                        = "600"
  filename                       = "pcc_loadticketsFn.zip"
  
  tracing_config {
    mode = "PassThrough"
  }
}

# Adding DynamoDB table for transactions
resource "aws_dynamodb_table" "tfer--pccdailytransactionreportt" {
  attribute {
    name = "Order ID"
    type = "S"
  }

  attribute {
    name = "TransactionID"
    type = "S"
  }

  billing_mode = "PROVISIONED"
  hash_key     = "TransactionID"
  name         = var.transactions_name_table

  point_in_time_recovery {
    enabled = "false"
  }

  range_key      = "Order ID"
  read_capacity  = "10"
  stream_enabled = "false"
  write_capacity = "10"
}

# Adding DynamoDB table for tickets
resource "aws_dynamodb_table" "tfer--pccdatafeedt" {
  attribute {
    name = "Barcode"
    type = "S"
  }

  attribute {
    name = "Order_ID"
    type = "S"
  }

  billing_mode = "PROVISIONED"
  hash_key     = "Barcode"
  name         = var.tickets_name_table

  point_in_time_recovery {
    enabled = "false"
  }

  range_key      = "Order_ID"
  read_capacity  = "10"
  stream_enabled = "false"
  table_class    = "STANDARD"
  write_capacity = "10"
}

# Adding IAM roles
resource "aws_iam_role" "tfer--pcc_dailytransactionFn-role-v0fpf6ka" {
  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  managed_policy_arns  = ["arn:aws:iam::439712476071:policy/service-role/AWSLambdaBasicExecutionRole-36645b1f-1f0a-4d17-a9cb-decccf697c76", "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess", "arn:aws:iam::aws:policy/AmazonS3FullAccess"]
  max_session_duration = "3600"
  name                 = "pcc_dailytransactionFn-role-v0fpf6ka"
  path                 = "/service-role/"
}

resource "aws_iam_role" "tfer--pcc_loadticketsFn-role-br00tq6v" {
  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  managed_policy_arns  = ["arn:aws:iam::439712476071:policy/service-role/AWSLambdaBasicExecutionRole-daf5335d-2d8e-4ad8-af09-937a40600818", "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess", "arn:aws:iam::aws:policy/AmazonS3FullAccess"]
  max_session_duration = "3600"
  name                 = "pcc_loadticketsFn-role-br00tq6v"
  path                 = "/service-role/"
}

# Adding IAM Policies
resource "aws_iam_policy" "tfer--AWSLambdaBasicExecutionRole-36645b1f-1f0a-4d17-a9cb-decccf697c76" {
  name = "AWSLambdaBasicExecutionRole-36645b1f-1f0a-4d17-a9cb-decccf697c76"
  path = "/service-role/"

  policy = <<POLICY
{
  "Statement": [
    {
      "Action": "logs:CreateLogGroup",
      "Effect": "Allow",
      "Resource": "arn:aws:logs:us-east-1:439712476071:*"
    },
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:logs:us-east-1:439712476071:log-group:/aws/lambda/pcc_dailytransactionFn:*"
      ]
    }
  ],
  "Version": "2012-10-17"
}
POLICY
}

resource "aws_iam_policy" "tfer--AWSLambdaBasicExecutionRole-daf5335d-2d8e-4ad8-af09-937a40600818" {
  name = "AWSLambdaBasicExecutionRole-daf5335d-2d8e-4ad8-af09-937a40600818"
  path = "/service-role/"

  policy = <<POLICY
{
  "Statement": [
    {
      "Action": "logs:CreateLogGroup",
      "Effect": "Allow",
      "Resource": "arn:aws:logs:us-east-1:439712476071:*"
    },
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:logs:us-east-1:439712476071:log-group:/aws/lambda/pcc_loadticketsFn:*"
      ]
    }
  ],
  "Version": "2012-10-17"
}
POLICY
}

resource "aws_iam_policy" "tfer--AWSLambdaS3ExecutionRole-f1dac8b6-4bb8-4e5b-adfa-f736c6af221a" {
  name = "AWSLambdaS3ExecutionRole-f1dac8b6-4bb8-4e5b-adfa-f736c6af221a"
  path = "/service-role/"

  policy = <<POLICY
{
  "Statement": [
    {
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::*"
    }
  ],
  "Version": "2012-10-17"
}
POLICY
}

# Adding IAM Policy attachments
resource "aws_iam_role_policy_attachment" "tfer--pcc_loadticketsFn-role-br00tq6v_AWSLambdaBasicExecutionRole-daf5335d-2d8e-4ad8-af09-937a40600818" {
  policy_arn = "arn:aws:iam::439712476071:policy/service-role/AWSLambdaBasicExecutionRole-daf5335d-2d8e-4ad8-af09-937a40600818"
  role       = "pcc_loadticketsFn-role-br00tq6v"
}

resource "aws_iam_role_policy_attachment" "tfer--pcc_loadticketsFn-role-br00tq6v_AmazonDynamoDBFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  role       = "pcc_loadticketsFn-role-br00tq6v"
}

resource "aws_iam_role_policy_attachment" "tfer--pcc_loadticketsFn-role-br00tq6v_AmazonS3FullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = "pcc_loadticketsFn-role-br00tq6v"
}

resource "aws_iam_role_policy_attachment" "tfer--pcc_dailytransactionFn-role-v0fpf6ka_AWSLambdaBasicExecutionRole-36645b1f-1f0a-4d17-a9cb-decccf697c76" {
  policy_arn = "arn:aws:iam::439712476071:policy/service-role/AWSLambdaBasicExecutionRole-36645b1f-1f0a-4d17-a9cb-decccf697c76"
  role       = "pcc_dailytransactionFn-role-v0fpf6ka"
}

resource "aws_iam_role_policy_attachment" "tfer--pcc_dailytransactionFn-role-v0fpf6ka_AmazonDynamoDBFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  role       = "pcc_dailytransactionFn-role-v0fpf6ka"
}

resource "aws_iam_role_policy_attachment" "tfer--pcc_dailytransactionFn-role-v0fpf6ka_AmazonS3FullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = "pcc_dailytransactionFn-role-v0fpf6ka"
}

# Adding S3 bucket as trigger to lambda and giving the permissions
resource "aws_s3_bucket_notification" "aws-lambda-transactions-trigger" {
  bucket = aws_s3_bucket.tfer--pccdailytransactionreport.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.tfer--pcc_dailytransactionFn.arn
    events              = ["s3:ObjectCreated:Put"]

  }
}

resource "aws_lambda_permission" "lambda-transactions-permission" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tfer--pcc_dailytransactionFn.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${aws_s3_bucket.tfer--pccdailytransactionreport.id}"
}

resource "aws_s3_bucket_notification" "aws-lambda-tickets-trigger" {
  bucket = aws_s3_bucket.tfer--pccdatafeed.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.tfer--pcc_loadticketsFn.arn
    events              = ["s3:ObjectCreated:Put"]

  }
}

resource "aws_lambda_permission" "lambda-tickets-permission" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tfer--pcc_loadticketsFn.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${aws_s3_bucket.tfer--pccdatafeed.id}"
}