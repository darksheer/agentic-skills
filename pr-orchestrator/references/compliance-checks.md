# Compliance Checks Reference

This document covers how the skill validates changes against project policies and regulatory frameworks.

## Project Policy Checks

### claude.md
If `claude.md` exists in the repo root (or a configured path), read it and check:
- **Coding conventions**: naming, formatting, architecture patterns
- **Forbidden patterns**: things explicitly prohibited
- **Required patterns**: things mandated for certain contexts (e.g., "all API endpoints must validate input")
- **Dependency policies**: allowed/prohibited dependencies

When a fix violates a `claude.md` rule, the skill must either adjust the fix to comply or skip the fix and annotate why.

### agents.md
If `agents.md` exists, read it and check:
- **Agent behavior guidelines**: how automated agents should interact with the codebase
- **Scope limitations**: what agents are and aren't allowed to change
- **Review requirements**: any special review requirements for agent-made changes

### Additional Policy Files
The config can list additional policy files to check:
```yaml
compliance:
  additional_policy_files:
    - CONTRIBUTING.md
    - SECURITY.md
    - docs/architecture-decisions/
```

For each, extract actionable constraints and validate changes against them.

## Regulatory Domain Checks

These are awareness flags — the skill is not a legal advisor. The report clearly states: "These flags highlight areas that may have regulatory implications. Consult your legal/compliance team for authoritative guidance."

### GDPR
Flag changes that:
- Add or modify collection of personal data (names, emails, IPs, device IDs)
- Change data retention or deletion logic
- Modify consent collection flows
- Add new third-party data sharing
- Change data processing purposes
- Modify data export/portability features

Keywords to scan for: `personal_data`, `user_data`, `email`, `consent`, `gdpr`, `data_subject`, `right_to_delete`, `data_export`, `privacy`, `cookie`, `tracking`

### HIPAA
Flag changes that:
- Touch health-related data models or fields
- Modify access control on health data
- Change audit logging for health data access
- Add new integrations that handle health data
- Modify encryption of health data at rest or in transit

Keywords: `patient`, `health`, `medical`, `diagnosis`, `treatment`, `hipaa`, `phi`, `protected_health`, `ehr`, `clinical`

### SOC2
Flag changes that:
- Modify authentication or authorization logic
- Change audit logging
- Modify data encryption
- Change access control policies
- Modify incident response code
- Change backup or recovery procedures

Keywords: `auth`, `permission`, `role`, `access_control`, `audit_log`, `encrypt`, `backup`, `security`, `credential`, `secret`

### PCI-DSS
Flag changes that:
- Touch payment processing code
- Modify cardholder data handling
- Change network segmentation
- Modify encryption of payment data
- Change access to payment systems

Keywords: `payment`, `card`, `pan`, `cvv`, `stripe`, `checkout`, `billing`, `transaction`, `merchant`

### CCPA
Flag changes that:
- Add data collection about California residents
- Modify opt-out mechanisms
- Change data sale or sharing logic
- Modify privacy notice content

Keywords: `ccpa`, `california`, `opt_out`, `do_not_sell`, `privacy_notice`, `consumer_rights`

### Licensing
Flag changes that:
- Add new dependencies
- Change license files
- Modify attribution notices

For new dependencies, check their license compatibility with the project's license. Common conflicts:
- GPL dependency in an MIT/Apache project
- AGPL dependency in a proprietary project
- License change in a dependency update

Use `license-checker`, `fossa`, or similar tools if available; otherwise inspect `package.json`, `Cargo.toml`, `go.mod`, `requirements.txt`, etc.

## Compliance Report Section

The compliance section of the final report follows this structure:

```markdown
## Compliance Status

### Project Policies
- claude.md: [PASS/FLAG] — [summary]
- agents.md: [PASS/FLAG/N/A] — [summary]
- CONTRIBUTING.md: [PASS/FLAG/N/A] — [summary]

### Regulatory Flags
[Only shown if legal_domains is configured]

| Domain | Status | Details |
|--------|--------|---------|
| GDPR | No flags | No changes to personal data handling |
| SOC2 | FLAG | Modified auth logic in `src/auth/handler.ts` — review recommended |

**Disclaimer:** These flags are automated awareness signals, not legal advice.
Consult your legal and compliance team for authoritative guidance on regulatory requirements.
```

## Implementation Notes

- Compliance checks run after all fixes are applied but before the final report
- If a compliance issue is found in a fix the skill itself applied, the skill should revert or adjust the fix
- Compliance failures in the original PR code (not introduced by fixes) are reported but not auto-fixed — they're flagged for the PR author
- The skill never makes legal determinations — it flags areas that may need human expert review
