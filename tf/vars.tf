variable "fauna_secret" {
  description = "FaunaDB server key"
}

variable "firebase_cred_file" {
  description = "Credentials JSON file for firebase"
}

variable "lambda_zip" {
  description = "path to zipped up lambda"
}

variable "lambda_handler" {
  description = "name of lambda handler"
}
