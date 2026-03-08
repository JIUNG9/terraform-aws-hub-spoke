---
name: Bug Report
about: Report a bug or unexpected behavior
title: "[BUG] "
labels: bug
assignees: ""
---

## Describe the Bug

A clear and concise description of what the bug is.

## Module

Which module is affected?

- [ ] `modules/vpc`
- [ ] `modules/tgw`
- [ ] `modules/tgw-attachment`
- [ ] Other / multiple modules

## Steps to Reproduce

1. Configure module with the following inputs:
```hcl
module "example" {
  source = "..."
  # paste your configuration here (redact sensitive values)
}
```
2. Run `terraform plan` or `terraform apply`
3. Observe error or unexpected behavior

## Expected Behavior

A clear and concise description of what you expected to happen.

## Actual Behavior

What actually happened. Include error messages if applicable.

## Terraform Output

```
# Paste relevant terraform plan/apply output here
```

## Environment

- **Terraform version**: (output of `terraform version`)
- **AWS Provider version**:
- **Module version/commit**:
- **AWS Region**:
- **OS**:

## Additional Context

Add any other context about the problem here. Screenshots, logs, or related issues.
