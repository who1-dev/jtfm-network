output "details" {
  description = "Map of available nacls"
  value = {
    for key, details in aws_network_acl.this : key => {
      id       = details.id
      arn      = details.arn
      owner_id = details.owner_id
    }
  }
}