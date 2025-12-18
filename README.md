# JTFM-Network
This Terraform module creates and manages a comprehensive AWS networking setup. It abstracts the complexity of configuring VPCs, Subnets, Network ACLs, Security Groups, and VPC Endpoints into a reusable module.


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#provider\_aws) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_nacls"></a> [nacls](#module\_nacls) | ./modules/nacls | n/a |
| <a name="module_subnets"></a> [subnets](#module\_subnets) | ./modules/subnets | n/a |

# Features

Based on the file structure, this module manages:

* **3-Tier VPC Architecture**
    * Automatically provisions `Public`, `Private`, and `Database` subnet layers across multiple Availability Zones.
    * Implements a structured naming convention (e.g., `1A1`, `1B1`) to easily identify Region/AZ/Subnet hierarchy.
    * Configurable DNS support and Hostname settings.

* **Flexible NAT Strategies (Connectivity)**
    * **High Availability vs. Cost Optimization:** Choose between deploying NAT Gateways in **all** Public AZs (Max HA) or specific subsets (Cost Saving) via `set_nat_deployment_az_location`.
    * Managed Elastic IP allocation for NAT resources.

* **Advanced Network ACLs (Stateless Security)**
    * **Automated Bidirectional Logic:** Optional flags (`is_bidirectional`) to automatically mirror inbound rules to outbound traffic, reducing configuration overhead.
    * **Common Rule Presets:** fast-track configuration by applying common protocol sets (e.g., `["HTTP", "HTTPS"]`) across specific network layers via `common_rules`.
    * **Granular Rule Maps:** Full control over Inbound and Outbound rules with support for specific rule numbers, protocols, and CIDR targets.

* **Security Groups (Stateful Firewalls)**
    * Simplified creation and association of Security Groups.
    * Supports dynamic ingress rule injection and `Security Group chaining (referencing other SGs by key)`.

* **Private Service Access**
    * Integrated configuration for `Interface VPC Endpoints (PrivateLink)`.
    * Simplified implementation using available endpoints [`'SSM'`, `SECRETSMANAGER`, `ECS`, `ECR` ]
    * Securely connects subnets to AWS services without traversing the public internet.

## Resources
> ### Core
| Name | Type |
|------|------|
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_internet_gateway.igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_nat_gateway.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |


> ### Sub-Module Resources 
| Name | Type |
|------|------|
| [module.subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [module.nacls](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |

> ### Security Groups
| Name | Type |
|------|------|
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_ingress_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |

> ### VPC Endpoints
| Name | Type |
|------|------|
| [aws_vpc_endpoint.interface](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |

## Data Sources
| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs
> ### Core
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env"></a> [env](#input\_env) | Deployment environment (e.g., dev, prod) | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Project namespace | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region to deploy resources | `string` | n/a | yes |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Default tags to be applied to all AWS resources | `map(any)` | n/a | yes |
> ### VPC
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cidr_block"></a> [cidr\_block](#input\_cidr\_block) | CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |
| <a name="input_enable_dns_hostnames"></a> [enable\_dns\_hostnames](#input\_enable\_dns\_hostnames) | Enable DNS hostnames in the VPC | `bool` | `false` | no |
| <a name="input_enable_dns_support"></a> [enable\_dns\_support](#input\_enable\_dns\_support) | Enable DNS support in the VPC | `bool` | `true` | no |
| <a name="input_instance_tenancy"></a> [instance\_tenancy](#input\_instance\_tenancy) | Instance tenancy for the VPC | `string` | `"default"` | no |
| <a name="input_azs"></a> [azs](#input\_azs) | List of Availability zones to be used in the VPC | `list(string)` | n/a | yes |

> ### NAT Gateways
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_nat_gateway"></a> [enable\_nat\_gateway](#input\_enable\_nat\_gateway) | Enable NAT Gateway for private subnets | `bool` | `false` | no |
| <a name="input_deploy_nat_in_all_public_azs"></a> [deploy\_nat\_in\_all\_public\_azs](#input\_deploy\_nat\_in\_all\_public\_azs) | Deploy NAT Gateways in all public subnet AZs if true, else use set\_nat\_deployment\_az\_location | `bool` | `true` | no |
| <a name="input_set_nat_deployment_az_location"></a> [set\_nat\_deployment\_az\_location](#input\_set\_nat\_deployment\_az\_location) | A list of Availability Zones to deploy NAT Gateways in. Must be a subset of var.azs. | `list(string)` | `[]` | no |

> ### VPC Endpoints
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_interface_endpoints"></a> [interface\_endpoints](#input\_interface\_endpoints) | Map of Interface VPC Endpoints | <pre>map(object({<br/>    subnet_keys         = list(string)<br/>    security_group_keys = list(string)<br/>  }))</pre> | `{}` | no |

> ### Subnets
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | Map of AZ keys to CIDR lists for public subnets | `map(list(string))` | `{}` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | Map of AZ keys to CIDR lists for private subnets | `map(list(string))` | `{}` | no |
| <a name="input_database_subnets"></a> [database\_subnets](#input\_database\_subnets) | Map of AZ keys to CIDR lists for database subnets | `map(list(string))` | `{}` | no |

> ### Security Groups
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | Map of security groups | <pre>map(object({<br/>    name        = string<br/>    description = string<br/>    rules = list(object({<br/>      port                          = number<br/>      cidr_block                    = optional(string)<br/>      referenced_security_group_key = optional(string, null)<br/>      ip_protocol                   = optional(string, "tcp")<br/>    }))<br/>  }))</pre> | `{}` | no |

> ### Network Access Control Lists
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_nacls_shared"></a> [nacls\_shared](#input\_nacls\_shared) | Common stateless network ACL rules intended for reuse across multiple subnet types. | <pre>map(object({<br/>    name             = optional(string)<br/>    is_bidirectional = optional(bool, true)<br/>    common_rules     = optional(list(string), [])<br/>    inbound_rules = optional(list(object({<br/>      rule_number     = number<br/>      protocol        = string<br/>      rule_action     = string<br/>      cidr_block      = optional(string)<br/>      ipv6_cidr_block = optional(string)<br/>      from_port       = number<br/>      to_port         = number<br/>    })), [])<br/>    outbound_rules = optional(list(object({<br/>      rule_number     = number<br/>      protocol        = string<br/>      rule_action     = string<br/>      cidr_block      = optional(string)<br/>      ipv6_cidr_block = optional(string)<br/>      from_port       = number<br/>      to_port         = number<br/>    })), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_nacls_public"></a> [nacls\_public](#input\_nacls\_public) | Map of Stateless firewall rules applied specifically to public subnet boundaries. | <pre>map(object({<br/>    name             = optional(string)<br/>    is_bidirectional = optional(bool, true)<br/>    common_rules     = optional(list(string), [])<br/>    inbound_rules = optional(list(object({<br/>      rule_number     = number<br/>      protocol        = string<br/>      rule_action     = string<br/>      cidr_block      = optional(string)<br/>      ipv6_cidr_block = optional(string)<br/>      from_port       = number<br/>      to_port         = number<br/>    })), [])<br/>    outbound_rules = optional(list(object({<br/>      rule_number     = number<br/>      protocol        = string<br/>      rule_action     = string<br/>      cidr_block      = optional(string)<br/>      ipv6_cidr_block = optional(string)<br/>      from_port       = number<br/>      to_port         = number<br/>    })), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_nacls_private"></a> [nacls\_private](#input\_nacls\_private) | Map of Stateless firewall rules applied specifically to private subnet boundaries. | <pre>map(object({<br/>    name             = optional(string)<br/>    is_bidirectional = optional(bool, true)<br/>    common_rules     = optional(list(string), [])<br/>    inbound_rules = optional(list(object({<br/>      rule_number     = number<br/>      protocol        = string<br/>      rule_action     = string<br/>      cidr_block      = optional(string)<br/>      ipv6_cidr_block = optional(string)<br/>      from_port       = number<br/>      to_port         = number<br/>    })), [])<br/>    outbound_rules = optional(list(object({<br/>      rule_number     = number<br/>      protocol        = string<br/>      rule_action     = string<br/>      cidr_block      = optional(string)<br/>      ipv6_cidr_block = optional(string)<br/>      from_port       = number<br/>      to_port         = number<br/>    })), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_nacls_database"></a> [nacls\_database](#input\_nacls\_database) | Map of Stateless firewall rules applied specifically to database subnet boundaries. | <pre>map(object({<br/>    name             = optional(string)<br/>    is_bidirectional = optional(bool, true)<br/>    common_rules     = optional(list(string), [])<br/>    inbound_rules = optional(list(object({<br/>      rule_number     = number<br/>      protocol        = string<br/>      rule_action     = string<br/>      cidr_block      = optional(string)<br/>      ipv6_cidr_block = optional(string)<br/>      from_port       = number<br/>      to_port         = number<br/>    })), [])<br/>    outbound_rules = optional(list(object({<br/>      rule_number     = number<br/>      protocol        = string<br/>      rule_action     = string<br/>      cidr_block      = optional(string)<br/>      ipv6_cidr_block = optional(string)<br/>      from_port       = number<br/>      to_port         = number<br/>    })), [])<br/>  }))</pre> | `{}` | no |



## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc"></a> [vpc](#output\_vpc) | VPC details |
| <a name="output_active_azs"></a> [active\_azs](#output\_active\_azs) | Map of active az location per Network Tiers: `Public`, `Private`, `Database` |
| <a name="output_igw_id"></a> [igw\_id](#output\_igw\_id) | IGW ID |
| <a name="output_nat_gateways"></a> [nat\_gateways](#output\_nat\_gateways) | NAT Gateways |
| <a name="output_security_groups"></a> [security\_groups](#output\_security\_groups) | List of available Security Groups |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | Map of available subnets per Network Tier : `Public`, `Private`, `Database` |
| <a name="output_nacls"></a> [subnets](#output\_nacls) | Map of available nacls per Tier : `Shared`, `Public`, `Private`, `Database` |
<!-- END_TF_DOCS -->