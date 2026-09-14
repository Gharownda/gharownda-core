# Gharownda Core contributor contract

Gharownda Core contains only genuinely reusable, independently documented building blocks. It must not become a mirror of private Gharownda product code, plans, data models, prompts, customer/family data, or product-specific policy.

## Contribution rules

- Extract only capabilities with a clear reusable boundary.
- Keep examples synthetic and product-neutral.
- Do not copy private repository documentation or implementation details into this repository.
- Prefer small, independently testable APIs over speculative frameworks.
- Maintainers own repository governance, releases, security policy, and extraction decisions.
- Automated workers may implement bounded low/medium-risk tasks but may not change governance, CI permissions, release policy, or security boundaries through the normal agent lane.
- Never commit secrets, production credentials, private data, or proprietary prompts/context.

When no reusable boundary exists yet, leaving this repository small is correct.
