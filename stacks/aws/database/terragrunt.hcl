include "root" {
  path = find_in_parent_folders("root.hcl")
}

exclude {
  if      = true
  actions = ["all"]
}

dependency "network" {
  config_path = "../network"

  mock_outputs = {
    data_subnet_ids        = ["subnet-mock1", "subnet-mock2"]
    data_security_group_id = "sg-mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}

terraform {
  source = "../../../modules/aws/database"
}

inputs = {
  region            = "ap-northeast-1"
  name              = "hetu-infra"
  subnet_ids        = dependency.network.outputs.data_subnet_ids
  security_group_id = dependency.network.outputs.data_security_group_id
  tags = {
    Project     = "hetu-infra"
    Environment = "demo"
    ManagedBy   = "hetu-infra"
  }
}
