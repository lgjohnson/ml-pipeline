variable "stack_env" {
    type = "string"
}

locals {
    training_lambda_function_name = "lgjohnson_ml_pipeline_training_lambda_${var.stack_env}"
}