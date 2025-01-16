<!-- markdownlint-disable -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |
| <a name="requirement_gitlab"></a> [gitlab](#requirement\_gitlab) | >= 17.7.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |
| <a name="provider_gitlab"></a> [gitlab](#provider\_gitlab) | >= 17.7.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cache"></a> [cache](#module\_cache) | cattle-ops/gitlab-runner/aws//modules/cache | 8.1.0 |
| <a name="module_instance_label"></a> [instance\_label](#module\_instance\_label) | cloudposse/label/null | 0.25.0 |
| <a name="module_runner"></a> [runner](#module\_runner) | cattle-ops/gitlab-runner/aws | 8.1.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role_policy_attachment.cache_bucket_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_ssm_parameter.token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [gitlab_user_runner.instance](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/user_runner) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>This is for some rare cases where resources want additional configuration of tags<br/>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>in the order they appear in the list. New attributes are appended to the<br/>end of the list. The elements of the list are joined by the `delimiter`<br/>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br/>See description of individual variables for details.<br/>Leave string and numeric variables as `null` to use default value.<br/>Individual variable settings (non-null) override settings in context object,<br/>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br/>  "additional_tag_map": {},<br/>  "attributes": [],<br/>  "delimiter": null,<br/>  "descriptor_formats": {},<br/>  "enabled": true,<br/>  "environment": null,<br/>  "id_length_limit": null,<br/>  "label_key_case": null,<br/>  "label_order": [],<br/>  "label_value_case": null,<br/>  "labels_as_tags": [<br/>    "unset"<br/>  ],<br/>  "name": null,<br/>  "namespace": null,<br/>  "regex_replace_chars": null,<br/>  "stage": null,<br/>  "tags": {},<br/>  "tenant": null<br/>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br/>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br/>Map of maps. Keys are names of descriptors. Values are maps of the form<br/>`{<br/>   format = string<br/>   labels = list(string)<br/>}`<br/>(Type is `any` so the map values can later be enhanced to provide additional options.)<br/>`format` is a Terraform format string to be passed to the `format()` function.<br/>`labels` is a list of labels, in order, to pass to `format()` function.<br/>Label values will be normalized before being passed to `format()` so they will be<br/>identical to how they appear in `id`.<br/>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_docker_auth_token"></a> [docker\_auth\_token](#input\_docker\_auth\_token) | A docker.io auth token (optional) | `string` | `""` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_fleeting_plugin_version"></a> [fleeting\_plugin\_version](#input\_fleeting\_plugin\_version) | Gitlab runner version | `string` | `"1.0.0"` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br/>Set to `0` for unlimited length.<br/>Set to `null` for keep the existing setting, which defaults to `0`.<br/>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | KMS key id to encrypted the resources. Ensure that your Runner/Executor has access to the KMS key. | `string` | `""` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>Does not affect keys of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper`.<br/>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br/>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br/>set as tag values, and output by this module individually.<br/>Does not affect values of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br/>Default is to include all labels.<br/>Tags with empty values will not be included in the `tags` output.<br/>Set to `[]` to suppress all generated tags.<br/>**Notes:**<br/>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br/>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br/>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br/>  "default"<br/>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>This is the only ID element not also included as a `tag`.<br/>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br/>Characters matching the regex will be removed from the ID elements.<br/>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_runner_ami_filter"></a> [runner\_ami\_filter](#input\_runner\_ami\_filter) | List of maps used to create the AMI filter for the Runner AMI. Must resolve to an Amazon Linux 1, 2 or 2023 image. | `map(list(string))` | <pre>{<br/>  "name": [<br/>    "al2023-ami-2023*-x86_64"<br/>  ]<br/>}</pre> | no |
| <a name="input_runner_ami_owners"></a> [runner\_ami\_owners](#input\_runner\_ami\_owners) | The list of owners used to select the AMI of the Runner instance. | `list(string)` | <pre>[<br/>  "amazon"<br/>]</pre> | no |
| <a name="input_runner_instances"></a> [runner\_instances](#input\_runner\_instances) | n/a | <pre>map(object({<br/>    untagged                = bool<br/>    runner_type             = string # project_type, group_type, instance_type<br/>    tag_list                = optional(list(string))<br/>    access_level            = optional(string, "not_protected") # not_protected, ref_protected<br/>    maintenance_note        = optional(string)<br/>    group_id                = optional(number)<br/>    project_id              = optional(number)<br/>    maximum_timeout         = optional(number)<br/>    paused                  = optional(bool)<br/>    description             = optional(string)<br/>    maximum_concurrent_jobs = optional(number, 5)<br/>    runner_instance_type    = optional(string, "t3.small")<br/>    worker_instance_types   = optional(list(string), ["t3a.medium", "t3.medium"])<br/>    autoscaling_options = optional(list(object({<br/>      periods            = list(string)<br/>      timezone           = optional(string, "UTC")<br/>      idle_count         = optional(number)<br/>      idle_time          = optional(string)<br/>      scale_factor       = optional(number)<br/>      scale_factor_limit = optional(number, 0)<br/>      })),<br/>      [<br/>        {<br/>          periods      = ["* * * * *"]<br/>          timezone     = "Europe/Berlin"<br/>          idle_count   = 0<br/>          idle_time    = "30m"<br/>          scale_factor = 2<br/>        },<br/>        {<br/>          periods      = ["* 7-19 * * mon-fri"]<br/>          timezone     = "Europe/Berlin"<br/>          idle_count   = 2<br/>          idle_time    = "30m"<br/>          scale_factor = 2<br/>        }<br/><br/>    ])<br/>  }))</pre> | n/a | yes |
| <a name="input_runner_version"></a> [runner\_version](#input\_runner\_version) | Gitlab runner version | `string` | `"17.7.0"` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet id used for the Runner and Runner Workers. Must belong to the `vpc_id`. In case the fleet mode is used, multiple subnets for<br/>the Runner Workers can be provided with runner\_worker\_docker\_machine\_instance.subnet\_ids. | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | The list of subnet IDs to use for the Runner Worker when the fleet mode is enabled. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `string` | n/a | yes |
| <a name="input_worker_ami_filter"></a> [worker\_ami\_filter](#input\_worker\_ami\_filter) | List of maps used to create the AMI filter for the Worker AMI. Should be Ubuntu | `map(list(string))` | <pre>{<br/>  "name": [<br/>    "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"<br/>  ]<br/>}</pre> | no |
| <a name="input_worker_ami_owners"></a> [worker\_ami\_owners](#input\_worker\_ami\_owners) | n/a | `list(string)` | <pre>[<br/>  "099720109477"<br/>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_runners"></a> [aws\_runners](#output\_aws\_runners) | n/a |
| <a name="output_gitlab_user_runners"></a> [gitlab\_user\_runners](#output\_gitlab\_user\_runners) | n/a |
| <a name="output_ssm_parameter_tokens"></a> [ssm\_parameter\_tokens](#output\_ssm\_parameter\_tokens) | n/a |
<!-- markdownlint-restore -->
