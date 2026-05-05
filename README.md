# Network Firewall Lab (ap-southeast-7)

## Overview
Lab environment to test Network Firewall + TGW routing cutover flow before production deployment.

## Architecture
```
TGW (Lab-TGW-01)
├── COMMON RT      → Shared Infra VPC
├── NONPROD RT     → DEV VPC (before cutover)
├── PROD RT        → PRD VPC (before cutover)
├── WORKLOAD RT    → DEV, PRD (after cutover) — all traffic via Firewall
├── FIREWALL RT    → Firewall attachment
└── SD-WAN RT      → SD-WAN (you configure)
```

## Resources Created
- 3 VPCs: DEV (10.100.32.0/19), PRD (10.100.192.0/19), Shared Infra (10.100.5.128/25)
- 1 TGW + 5 Route Tables
- 1 Network Firewall (TGW attachment mode)
- 6+ Firewall Rule Groups
- 4 AWS Managed Rules (BotNet, Malware)
- 2 CloudWatch Log Groups (FLOW + ALERT)
- SD-WAN placeholder (TGW Connect + BGP peer)

## Deploy
Via GitHub Actions:
1. Push to `main` → Terraform Apply runs automatically
2. PR to `main` → Terraform Plan runs for review

## Test Flow
1. `terraform apply` — deploy everything
2. Test DEV → PRD without Firewall (NONPROD RT)
3. Cutover: move DEV to WORKLOAD RT (uncomment in tgw.tf)
4. Test DEV → PRD through Firewall (check logs)
5. Rollback: move DEV back to NONPROD RT
6. SD-WAN: configure appliance + BGP (you do this)
7. Uncomment static routes per wave

## Region
ap-southeast-7 (Thailand)

## Account
176501510816
