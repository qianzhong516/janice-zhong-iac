resource "aws_dynamodb_table" "visits" {
  name         = "visits"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = var.tags
}

resource "aws_dynamodb_table_item" "visit-items" {
  table_name = aws_dynamodb_table.visits.name
  hash_key   = aws_dynamodb_table.visits.hash_key

  item = <<ITEM
    {
        "id": {"S": "1"},
        "visitCount": {"N": "0"}
    }
  ITEM
}