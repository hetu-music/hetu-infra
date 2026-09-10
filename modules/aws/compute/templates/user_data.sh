#!/bin/bash
# Bootstraps Docker on a fresh Amazon Linux 2023 instance. Neither kato-config's ansible role
# nor the AMI installs Docker itself — this is the one place that gap gets closed.
set -eux

dnf install -y docker
systemctl enable --now docker
usermod -aG docker ec2-user

# AL2023's docker package doesn't ship the Compose v2 CLI plugin, so pull the latest release
# binary directly rather than pin a version here that will go stale.
mkdir -p /usr/local/lib/docker/cli-plugins
COMPOSE_VERSION=$(curl -fsSL https://api.github.com/repos/docker/compose/releases/latest \
  | grep -m1 '"tag_name"' | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/')
curl -fsSL "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-linux-$(uname -m)" \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
