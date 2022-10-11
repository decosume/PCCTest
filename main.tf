provider "aws" {
  region =var.aws_region
}

# Adding S3 buckets for tickets and transactions
resource "aws_s3_bucket" "pccdailytransactionreport" {
  bucket        = var.bucket_name_transactions
  acl           = "private"

  versioning {
    enabled    = "true"
 }
}

resource "aws_s3_bucket" "pccdatafeed" {
  bucket        = var.bucket_name_tickets
  acl           = "private"

  versioning {
    enabled    = "true"
  }
}

# Adding Lambda function for transactions
resource "aws_lambda_function" "pcc_dailytransactionFn" {
  architectures = ["x86_64"]

  ephemeral_storage {
    size = "1024"
  }

  function_name                  = var.transactions_name_function
  handler                        = "lambda_function.lambda_handler"
  memory_size                    = "512"
  package_type                   = "Zip"
  reserved_concurrent_executions = "-1"
  role                           = "${aws_iam_role.pcc_dailytransactionFn-role-v0fpf6ka.arn}"  
  runtime                        = "python3.9"
  source_code_hash               = "9HQJd9/HuwpLTELojtyUKy+BFksKi7crG6uN8KD4PB4="
  timeout                        = "300"
  filename                       = "pcc_dailytransactionFn.zip"

}

# Adding Lambda function for tickets
resource "aws_lambda_function" "pcc_loadticketsFn" {
  architectures = ["x86_64"]

  ephemeral_storage {
    size = "1024"
  }

  function_name                  = var.tickets_name_function
  handler                        = "lambda_function.lambda_handler"
  memory_size                    = "256"
  package_type                   = "Zip"
  reserved_concurrent_executions = "-1"
  role                           = "${aws_iam_role.pcc_loadticketsFn-role-br00tq6v.arn}"
  runtime                        = "python3.9"
  source_code_hash               = "EIJpgfnfG0LlyzuO3os70seSv5pxRZJ1XluReHfQnC0="
  timeout                        = "600"
  filename                       = "pcc_loadticketsFn.zip"
  
}

# Adding DynamoDB table for transactions
resource "aws_dynamodb_table" "pccdailytransactionreportt" {
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
resource "aws_dynamodb_table" "pccdatafeedt" {
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
resource "aws_iam_role" "pcc_dailytransactionFn-role-v0fpf6ka" {
  name = "pcc_dailytransactionFn-role-v0fpf6ka"
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
}

resource "aws_iam_role" "pcc_loadticketsFn-role-br00tq6v" {
  name="pcc_loadticketsFn-role-br00tq6v"
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
}

# Adding IAM Policies
resource "aws_iam_policy" "AWSLambdaBasicExecutionRole-36645b1f-1f0a-4d17-a9cb-decccf697c76" {
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
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": [
         "arn:aws:logs:*:*:*"
      ]
    }
  ],
  "Version": "2012-10-17"
}
POLICY
}

resource "aws_iam_policy" "AWSLambdaBasicExecutionRole-daf5335d-2d8e-4ad8-af09-937a40600818" {
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
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:logs:*:*:*"
      ]
    }
  ],
  "Version": "2012-10-17"
}
POLICY
}

# Adding IAM Policy attachments
resource "aws_iam_role_policy_attachment" "pcc_dailytransactionFn-role-v0fpf6ka_AWSLambdaBasicExecutionRole-36645b1f-1f0a-4d17-a9cb-decccf697c76" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = "pcc_dailytransactionFn-role-v0fpf6ka"
}

resource "aws_iam_role_policy_attachment" "pcc_dailytransactionFn-role-v0fpf6ka_AmazonDynamoDBFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  role       = "pcc_dailytransactionFn-role-v0fpf6ka"
}

resource "aws_iam_role_policy_attachment" "pcc_dailytransactionFn-role-v0fpf6ka_AmazonS3FullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = "pcc_dailytransactionFn-role-v0fpf6ka"
}

resource "aws_iam_role_policy_attachment" "pcc_loadticketsFn-role-br00tq6v_AWSLambdaBasicExecutionRole-daf5335d-2d8e-4ad8-af09-937a40600818" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = "pcc_loadticketsFn-role-br00tq6v"
}

resource "aws_iam_role_policy_attachment" "pcc_loadticketsFn-role-br00tq6v_AmazonDynamoDBFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  role       = "pcc_loadticketsFn-role-br00tq6v"
}

resource "aws_iam_role_policy_attachment" "pcc_loadticketsFn-role-br00tq6v_AmazonS3FullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = "pcc_loadticketsFn-role-br00tq6v"
}

# Adding S3 buckets as trigger to lambda and giving the permissions
resource "aws_s3_bucket_notification" "aws-lambda-transactions-trigger" {
  bucket = aws_s3_bucket.pccdailytransactionreport.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.pcc_dailytransactionFn.arn
    events              = ["s3:ObjectCreated:Put"]
  }
  depends_on = [aws_lambda_permission.lambda-transactions-permission]
}

resource "aws_lambda_permission" "lambda-transactions-permission" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pcc_dailytransactionFn.arn
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${aws_s3_bucket.pccdailytransactionreport.id}"
}

resource "aws_s3_bucket_notification" "aws-lambda-tickets-trigger" {
  bucket = aws_s3_bucket.pccdatafeed.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.pcc_loadticketsFn.arn
    events              = ["s3:ObjectCreated:Put"]

  }
}

resource "aws_lambda_permission" "lambda-tickets-permission" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pcc_loadticketsFn.arn
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${aws_s3_bucket.pccdatafeed.id}"
}

# Adding Autoscaling to DynamoDb tables
# TBD

