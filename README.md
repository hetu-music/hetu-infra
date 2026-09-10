# hetu-infra

Infrastructure as Code (IaC) repository for Hetu Music.

## Overview

This repository manages cloud infrastructure and configurations across:
- **AWS**: Compute, storage, and networking resources.
- **Cloudflare**: DNS, CDN, and edge security settings.

## Project Structure

```text
├── modules/          # Reusable infrastructure modules (AWS, Cloudflare, etc.)
│   ├── aws/
│   └── cloudflare/
├── stacks/           # Environment and stack deployments
└── .github/          # CI/CD workflows and automation
```

## Getting Started

1. Ensure required CLI tools (Terraform/OpenTofu, AWS CLI, etc.) are installed and configured.
2. Navigate to the desired stack under `stacks/`.
3. Plan and apply changes according to team deployment guidelines.
