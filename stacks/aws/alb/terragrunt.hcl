include "root" {
  path = find_in_parent_folders("root.hcl")
}

skip = true

dependency "network" {
  config_path = "../network"

  mock_outputs = {
    vpc_id                = "vpc-mock"
    public_subnet_ids     = ["subnet-mock1", "subnet-mock2"]
    alb_security_group_id = "sg-mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}

terraform {
  source = "../../../modules/aws/alb"
}

inputs = {
  region            = "ap-northeast-1"
  name              = "hetu-infra"
  vpc_id            = dependency.network.outputs.vpc_id
  public_subnet_ids = dependency.network.outputs.public_subnet_ids
  security_group_id = dependency.network.outputs.alb_security_group_id

  # certificate_arn = dependency.acm.outputs.certificate_arn

  tags = {
    Project     = "hetu-infra"
    Environment = "demo"
    ManagedBy   = "hetu-infra"
  }
}
