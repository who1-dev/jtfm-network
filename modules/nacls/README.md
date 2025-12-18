<!-- BEGIN_TF_DOCS -->
## NACL Module
This module utilizes a Stateless Rule Factory to simplify and automate NACL management. It merges reusable security templates with custom rules to maintain consistency, while automatically injecting ephemeral port rules (1024-65535) to handle the "stateless" nature of return traffic. By flattening complex data into unique, deterministic identifiers, it allows a single resource block to scale across hundreds of rules without naming conflicts or manual configuration errors.

## Requirements
- `NACL Type`: should always be standard at Parent Module. e.g shared, public, private, database. `changes of these keys will result to implementation drift.`
 - 
- `NACLS`: schema for this input should always implement the tier setup.

`Sample Map iterated from parent module`
```
nacls = {
  shared = {
    "SHARED_PUBLIC" = {
        name         = "SHARED_PUBLIC-NACL"
        common_rules = ["HHTP", "HTTPS"]
    }
  }     
  public = {
    "1B1" = {
        is_bidirectional = true
        common_rules     = []
        inbound_rules = [
            {
                rule_number = 100
                protocol    = "tcp"
                rule_action = "allow"
                cidr_block  = "0.0.0.0/0"
                from_port   = 22
                to_port     = 22
            }
        ]
    }
  }
  private = {
    "1A1" = {
        is_bidirectional = true
        common_rules     = ["HTTPS"]
    }
  }
}
```

## Resources

| Name | Type |
|------|------|
| [aws_network_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl_rule.rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Project namespace | `string` | n/a | yes |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Default tags to apply to resources | `map(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where nacls will be created | `string` | n/a | yes |
| <a name="input_nacl_type"></a> [nacl\_type](#input\_nacl\_type) | Type of nacls (public, private, or database) | `string` | n/a | yes |
| <a name="input_nacls"></a> [nacls](#input\_nacls) | Map of Public NACLs to create per subnet type | <pre>map(object({<br/>    name             = optional(string)<br/>    is_bidirectional = optional(bool, true)<br/>    common_rules     = optional(list(string), [])<br/>    inbound_rules = optional(list(object({<br/>      rule_number     = number<br/>      protocol        = string<br/>      rule_action     = string<br/>      cidr_block      = optional(string)<br/>      ipv6_cidr_block = optional(string)<br/>      from_port       = number<br/>      to_port         = number<br/>    })), [])<br/>    outbound_rules = optional(list(object({<br/>      rule_number     = number<br/>      protocol        = string<br/>      rule_action     = string<br/>      cidr_block      = optional(string)<br/>      ipv6_cidr_block = optional(string)<br/>      from_port       = number<br/>      to_port         = number<br/>    })), [])<br/>  }))</pre> | `{}` | no |


## Outputs

| Name | Description |
|------|-------------|
| <a name="output_details"></a> [details](#output\_details) | Map of available nacls |
<!-- END_TF_DOCS -->