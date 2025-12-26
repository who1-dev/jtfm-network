locals {
  REGEX_AZ_SHORT = "([0-9]+[a-z])"
}

output "details" {
  description = "Map of available subnets"
  value = {
    for key, details in aws_subnet.this : key => {
      id         = details.id
      arn        = details.arn
      az         = details.availability_zone
      short_az   = var.dict_azs[details.availability_zone]
      cidr_block = details.cidr_block
    }
  }
}