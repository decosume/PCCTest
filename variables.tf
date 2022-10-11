
#Create Variables
variable "aws_region" {
  default     = "us-east-1"
}

variable "bucket_name_tickets" {
  default = "pccdatafeed-tech9"
}

variable "bucket_name_transactions" {
  default = "pccdailytransactionreport-tech9"
}

variable "tickets_name_function" {
  default = "pcc_loadticketsFn"
}

variable "transactions_name_function" {
  default = "pcc_dailytransactionFn"
}

variable "tickets_name_table" {
  default = "pccdatafeedt"
}

variable "transactions_name_table" {
  default = "pccdailytransactionreportt"
}