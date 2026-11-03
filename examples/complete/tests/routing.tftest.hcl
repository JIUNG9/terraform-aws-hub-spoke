# Routing test for the complete example: the hub reaches every spoke, every
# spoke reaches the hub, and prod and stage cannot reach each other.
#
# The AWS provider is mocked and the VPC modules are overridden with fixed
# outputs, so this runs with no credentials and creates nothing.
#
#   cd examples/complete && terraform init -backend=false && terraform test
#
# On a Transit Gateway, A can send to B when B's CIDR is in the route table A is
# associated with. B's CIDR is in that table when B's attachment propagates into
# it. So "A reaches B" is: B's propagated tables contain A's associated table.

mock_provider "aws" {}

mock_provider "aws" {
  alias = "prod"
}

mock_provider "aws" {
  alias = "stage"
}

override_module {
  target = module.hub_vpc
  outputs = {
    vpc_id                  = "vpc-0hub"
    vpc_cidr_block          = "10.0.0.0/16"
    private_subnet_ids      = ["subnet-0hub1", "subnet-0hub2"]
    private_route_table_id  = "rtb-0hubpriv"
    database_route_table_id = "rtb-0hubdb"
  }
}

override_module {
  target = module.prod_vpc
  outputs = {
    vpc_id                  = "vpc-0prod"
    vpc_cidr_block          = "10.1.0.0/16"
    private_subnet_ids      = ["subnet-0prod1", "subnet-0prod2"]
    private_route_table_id  = "rtb-0prodpriv"
    database_route_table_id = "rtb-0proddb"
  }
}

override_module {
  target = module.stage_vpc
  outputs = {
    vpc_id                  = "vpc-0stage"
    vpc_cidr_block          = "10.50.0.0/16"
    private_subnet_ids      = ["subnet-0stage1", "subnet-0stage2"]
    private_route_table_id  = "rtb-0stagepriv"
    database_route_table_id = "rtb-0stagedb"
  }
}

variables {
  prod_account_id  = "111122223333"
  stage_account_id = "987654321098"
}

run "hub_has_its_own_route_table" {
  command = apply

  assert {
    condition     = module.hub_attachment.associated_route_table_id == module.tgw.hub_route_table_id
    error_message = "the hub attachment must be associated with the hub route table"
  }

  assert {
    condition     = !contains(values(module.tgw.route_table_ids), module.tgw.hub_route_table_id)
    error_message = "the hub route table must not be one of the environment tables"
  }
}

run "hub_reaches_every_spoke" {
  command = apply

  assert {
    condition     = contains(module.prod_attachment.propagated_route_table_ids, module.hub_attachment.associated_route_table_id)
    error_message = "hub -> prod: prod must propagate into the table the hub is associated with"
  }

  assert {
    condition     = contains(module.stage_attachment.propagated_route_table_ids, module.hub_attachment.associated_route_table_id)
    error_message = "hub -> stage: stage must propagate into the table the hub is associated with"
  }
}

run "every_spoke_reaches_the_hub" {
  command = apply

  assert {
    condition     = contains(module.hub_attachment.propagated_route_table_ids, module.prod_attachment.associated_route_table_id)
    error_message = "prod -> hub: the hub must propagate into the table prod is associated with"
  }

  assert {
    condition     = contains(module.hub_attachment.propagated_route_table_ids, module.stage_attachment.associated_route_table_id)
    error_message = "stage -> hub: the hub must propagate into the table stage is associated with"
  }
}

run "prod_and_stage_cannot_reach_each_other" {
  command = apply

  assert {
    condition     = !contains(module.stage_attachment.propagated_route_table_ids, module.prod_attachment.associated_route_table_id)
    error_message = "prod -> stage: stage must not propagate into the table prod is associated with"
  }

  assert {
    condition     = !contains(module.prod_attachment.propagated_route_table_ids, module.stage_attachment.associated_route_table_id)
    error_message = "stage -> prod: prod must not propagate into the table stage is associated with"
  }
}
