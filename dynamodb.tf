resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_dynamodb_table" "visits" {
  # having an auto-generated table name to allow table replacement changes
  name         = "visits-${random_id.suffix.hex}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = var.tags
}