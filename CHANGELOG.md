# Changelog

## [Unreleased]

### Added
- `terraform test` suite for the `vpc` module's input validations (`modules/vpc/tests/`), run on a mocked AWS provider; `make test` now runs it
- `enable_nat_gateway` validation: a NAT gateway needs at least one public subnet, instead of failing with `Invalid index` at plan time

### Fixed
- `make test` pointed at a `tests/` Go directory that was never committed

## [0.4.0] - 2026-04-08

### Added
- Default security group lockdown (Checkov CKV2_AWS_12)
- SSM Parameter Store metadata sync for cross-stack reference
- terraform-docs configuration
- Makefile for common operations

## [0.3.0] - 2026-03-31

### Added  
- Terratest framework with plan-only tests for all modules
- Example validation tests
- Go test infrastructure

## [0.2.0] - 2026-03-24

### Added
- Gateway VPC endpoints (S3, DynamoDB)
- Interface VPC endpoints (SSM, ECR, CloudWatch) with security group
- Static and blackhole route support for TGW
- CIDR convention enforcement variable

## [0.1.0] - 2026-03-08

### Added
- Initial release: VPC, TGW, TGW-attachment modules
- Complete and simple examples with cross-account providers
- CI pipeline: fmt, validate, tflint, checkov
