# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## Brimir unreleased.unreleased.unreleased (to be announced)
### Added
- Ability to filter on incoming email address. Note that this only works for addresses that are first added and verified as outgoing addresses.
- Agents can now also be limited to certain labels, which lets them only manage tickets and replies with those labels.
- If a ticket detail page is opened by an agent, it will be locked to avoid multiple agents from replying to the same ticket. Tickets are unlocked five minutes after the agent leaves the ticket detail page or by clicking the link on ticket detail by not limited agents.

### Changed
- The outgoing email address of replies will now be the same as the original incoming email addresses when it was configured correctly as an outgoing email address. The agent can choose a different address when replying.
- The `script/post-mail` script now returns correct exit codes to the local delivery command of Postfix. This allows Postfix to bounce an email when the ticket could not be created.

### Fixed
- The content of inline HTML style tags is now correctly removed as well.
