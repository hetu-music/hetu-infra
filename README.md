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