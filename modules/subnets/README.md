<!-- BEGIN_TF_DOCS -->
# Subnet Module
Handles the generation of structured naming convention (e.g., 1A1, 1B1) to easily identify Region/AZ/Subnet hierarchy.

## Requirements
- `Subnet Type`: should always be standard at Parent Module. e.g public, private, database `changes of these keys will result to implementation drift.` 
- `Subnets`: schema for this input should always implement the network tier setup. {public : { ...}}

`Sample Map iterated from parent module`
```
subnets = {
  public = {
    "us-east-1a" = ["10.0.1.0/24","10.0.2.0/24"]
    "us-east-1b" = ["10.0.5.0/24"]
  }
  private = {
    "us-east-1a" = ["10.0.10.0/24"]
    "us-east-1b" = ["10.0.11.0/24"]
  }
  database = {
    "us-east-1b" = ["10.0.200.0/24"]
  }
}
```


## Resources

| Name | Type |
|------|------|
| [aws_subnet.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Project namespace | `string` | n/a | yes |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Default tags to apply to resources | `map(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where subnets will be created | `string` | n/a | yes |
| <a name="input_dict_azs"></a> [dict\_azs](#input\_dict\_azs) | Dictionary of AZs: { {`us-east-1a` : `1A`}, { `1A`: `us-east-1a` } } | `any` | n/a | yes |
| <a name="input_subnet_type"></a> [subnet\_type](#input\_subnet\_type) | Type of subnet (public, private, or database) | `string` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Map of subnets CIDRs per AZ | `map(list(string))` | n/a | yes |


## Outputs

| Name | Description |
|------|-------------|
| <a name="output_details"></a> [details](#output\_details) | Map of available subnets |
<!-- END_TF_DOCS -->