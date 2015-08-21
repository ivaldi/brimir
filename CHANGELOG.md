# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## Brimir unreleased.unreleased.unreleased (to be announced)
### Added
- Russian translation was improved by @mpakus.
- Google Account single-sign on support was contributed by @FloHin.
- LDAP authentication was contributed by @alisnic.
- Arabic translation contributed by @modsaid.
- Brazillian Portugues translation was drasitcally improved by @DadoCe.
- A complety new design was implemented.
- User avatar support was contributed by @fiedl.
- Ability to filter on incoming email address. Note that this only works for addresses that are first added and verified as outgoing addresses.
- Agents can now also be limited to certain labels, which lets them only manage tickets and replies with those labels.
- If a ticket detail page is opened by an agent, it will be locked to avoid multiple agents from replying to the same ticket. Tickets are unlocked five minutes after the agent leaves the ticket detail page or by clicking the link on ticket detail by not limited agents.
- The status of a ticket can now be changed directly when adding a reply.
- Nice name outgoing email address support, i.e. `From: Test <test@test.nl>` instead of just the email address.

### Changed
- The outgoing email address of replies will now be the same as the original incoming email addresses when it was configured correctly as an outgoing email address. The agent can choose a different address when replying.
- The `script/post-mail` script now returns correct exit codes to the local delivery command of Postfix. This allows Postfix to bounce an email when the ticket could not be created.

### Deprecated
- Support for Ruby 1.9 has been dropped. We're not automatically testing it anymore.

### Removed
- Database migrations from Markdown to HTML and required gems.

### Fixed
- More robust incoming email support.
- The content of inline HTML style tags is now correctly removed as well.
- Adding of labels to tickets updates the interface correctly again, this was broken since the redesign.
