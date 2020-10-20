# -------------------------------------------------------------------
# iam
resource "aws_iam_policy" "policy" {
  name        = var.aws_iam_policy_name
  path        = var.aws_iam_policy_path
  description = var.aws_iam_policy_description

  policy = var.aws_iam_policy_policy
}

resource "aws_iam_role" "role" {
  name = var.aws_iam_role_name
  assume_role_policy = var.aws_iam_role_assume_role_policy
}

resource "aws_iam_policy_attachment" "attach" {
  name       = var.aws_iam_policy_attachment_name
  roles      = [aws_iam_role.role.name]
  policy_arn = aws_iam_policy.policy.arn
}

# -------------------------------------------------------------------
# dynamodb
resource "aws_dynamodb_table" "table" {
  name = var.aws_dynamodb_table_name
  hash_key = var.aws_dynamodb_table_key
  read_capacity  = var.aws_dynamodb_table_capacity
  write_capacity = var.aws_dynamodb_table_capacity

  attribute {
    name = var.aws_dynamodb_table_key
    type = var.aws_dynamodb_table_type
  }
}