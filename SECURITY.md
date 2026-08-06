# Security Policy

## Reporting a vulnerability

**Please don't open a public issue for a security problem.**

Report it privately through GitHub:
[**Report a vulnerability**](https://github.com/JIUNG9/terraform-aws-hub-spoke/security/advisories/new)

That opens an advisory visible only to you and the maintainer — no email address to
track down, and nothing public until there's a fix.

> **Maintainer note:** that link requires *Private vulnerability reporting* to be
> switched on under **Settings → Advanced Security**. It's one checkbox and it's
> free on public repos. Until it's enabled the URL 404s for outside reporters, so
> turn it on before pointing anyone at this policy.

### What helps

- What the issue is, and what an attacker gets out of it
- The module and variable combination that triggers it
- `terraform plan` output showing the resulting resource, where that makes it clearer
- A suggested fix, if you have one in mind

### What to expect

This is a personally maintained project rather than a funded product, so response is
best-effort: acknowledgement within a few days, and a fix prioritised by severity.

## Supported versions

Only `main` and the latest tag get fixes. Pin to a tag and upgrade deliberately to
pick up changes.

## Scope

These modules build network boundaries, so a defect here is a hole in someone's
perimeter. In scope:

- A default that exposes something publicly — a security group opening `0.0.0.0/0`,
  a subnet auto-assigning public IPs where the variable says otherwise, a route
  sending traffic somewhere it shouldn't.
- Transit Gateway routing that reaches across an account boundary the topology is
  meant to isolate. The point of hub-spoke here is that spokes can't talk to each
  other except through the hub.
- `enforce_cidr_convention` failing to reject an out-of-band CIDR when it's enabled.
  This input was documented for months while nothing read it, so it's worth
  re-verifying rather than trusting.
- Anything that writes an account ID, ARN or CIDR of a real estate into module
  defaults, examples or outputs.

Out of scope: the `examples/` directory, which uses placeholder account IDs and is
documented as illustrative rather than production-ready.
