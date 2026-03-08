# Contributing to terraform-aws-hub-spoke

Thank you for your interest in contributing. This document provides guidelines and instructions for contributing to this project.

## Getting Started

1. **Fork** the repository on GitHub
2. **Clone** your fork locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/terraform-aws-hub-spoke.git
   cd terraform-aws-hub-spoke
   ```
3. **Create a branch** for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Requirements

- Terraform >= 1.10.0
- TFLint (latest)
- Checkov (for security scanning)

## Making Changes

### Code Conventions

- Run `terraform fmt -recursive` before committing
- All variables must have `description` and `type` defined
- All modules must include `required_version` and `required_providers` in a `versions.tf` or within `main.tf`
- Follow the naming convention: `{org}-{group}-{service}-{region}-{env}-{type}`
- Use meaningful resource names and avoid generic names like `this` or `main` unless contextually appropriate

### Module Structure

Each module should follow this structure:

```
modules/<module-name>/
  main.tf          # Primary resources
  variables.tf     # Input variables
  outputs.tf       # Output values
  README.md        # Module documentation
```

### Commit Messages

Use clear, descriptive commit messages:

```
feat(vpc): add support for IPv6 CIDR blocks
fix(tgw): correct route propagation for cross-account attachments
docs: update CIDR allocation table in README
```

Prefixes:
- `feat` -- New feature
- `fix` -- Bug fix
- `docs` -- Documentation changes
- `refactor` -- Code restructuring without behavior change
- `test` -- Adding or updating tests
- `chore` -- Maintenance tasks

## Submitting a Pull Request

1. **Push** your branch to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```
2. **Open a Pull Request** against the `main` branch of this repository
3. **Fill in the PR template** with:
   - Summary of changes
   - Which modules are affected
   - How to test the changes
   - Any breaking changes

### PR Checklist

Before submitting, verify:

- [ ] `terraform fmt -recursive` passes with no changes
- [ ] `terraform validate` passes for all affected modules
- [ ] TFLint reports no errors
- [ ] Variables have descriptions and types
- [ ] Outputs have descriptions
- [ ] Module README is updated if inputs/outputs changed
- [ ] Examples are updated if the module interface changed

## Reporting Issues

- Use the [Bug Report](.github/ISSUE_TEMPLATE/bug_report.md) template for bugs
- Use the [Feature Request](.github/ISSUE_TEMPLATE/feature_request.md) template for enhancements
- Include Terraform version, provider version, and relevant configuration (redact sensitive values)

## Code of Conduct

Be respectful and constructive. We are all here to build better infrastructure tooling together.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
