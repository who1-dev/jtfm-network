output "details" {
  description = "List of available subnets"
  value = {
    for key, details in aws_network_acl.this : key => {
      id       = details.id
      arn      = details.arn
      owner_id = details.owner_id
    }
  }
}