include "root" {
  path = find_in_parent_folders("root.hcl")
}

skip = true

dependency "network" {
  config_path = "../network"

  mock_outputs = {
    app_subnet_ids        = ["subnet-mock1", "subnet-mock2"]
    app_security_group_id = "sg-mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}

dependency "iam" {
  config_path = "../iam"

  mock_outputs = {
    ec2_instance_profile_name = "mock-profile"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}

dependency "alb" {
  config_path = "../alb"

  mock_outputs = {
    target_group_arn = "arn:aws:elasticloadbalancing:ap-northeast-1:000000000000:targetgroup/mock/0000000000000000"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}

terraform {
  source = "../../../modules/aws/compute"
}

inputs = {
  region                = "ap-northeast-1"
  name                  = "hetu-infra"
  subnet_ids            = dependency.network.outputs.app_subnet_ids
  security_group_id     = dependency.network.outputs.app_security_group_id
  instance_profile_name = dependency.iam.outputs.ec2_instance_profile_name
  target_group_arns     = [dependency.alb.outputs.target_group_arn]

  tags = {
    Project     = "hetu-infra"
    Environment = "demo"
    ManagedBy   = "hetu-infra"
  }
}
