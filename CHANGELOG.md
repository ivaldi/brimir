# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## Brimir unreleased.unreleased.unreleased (to be announced)
### Added
### Changed
- Lines of plain text tickets or replies are now wrapped at 72 characters.
- The rule action to notify users now creates users if they don't exist yet.
### Deprecated
### Removed
### Fixed
- French translation was imprroved by @sapk.
### Security

## Brimir 0.6.1 (2015-10-02)
### Changed
- A number of missing German translations were contributed by Alexander Jackson.
- CC and BCC addresses are now recognized as incoming address as well.
### Fixed
- Prevented errors when using draft sharing.

## Brimir 0.6.0 (2015-09-18)
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
- Opt-in other users in conversations.
- Filter users by type and/or email.
- It is now possible to inline-edit the label name.
- Per user configuration option for plain text replies.
- A global configuration page was added which can be used to set default locale and time zone.
- Added "equal to" as option for rule matching.
- Original email messages are now stored and available from the ticket detail page. This can be helpfull if Brimir fails to show some HTML mails correctly or to resolve possible bugs in Brimir.
- Farsi/Persian translation contributed by @hadifarnoud.
- Support for inline email attachments has been added. It will only work for newly received messages.
- Filter by user from tickets index. Contributed by @fiedl.
- It is now possible to save drafts. They can be shared with other agents using a global configuration option.
- Users without tickets and replies can now be removed.

### Changed
- The outgoing email address of replies will now be the same as the original incoming email addresses when it was configured correctly as an outgoing email address. The agent can choose a different address when replying.
- The `script/post-mail` script now returns correct exit codes to the local delivery command of Postfix. This allows Postfix to bounce an email when the ticket could not be created.
- Ordering of tickets is now based on last modified time. Tickets with new replies will show up on top.
- Filter values are now case insensitive.

### Deprecated
- Support for Ruby 1.9 has been dropped. We're not automatically testing it anymore.

### Removed
- Database migrations from Markdown to HTML and required gems.

### Fixed
- More robust incoming email support.
- The content of inline HTML style tags is now correctly removed as well.
- Adding of labels to tickets updates the interface correctly again, this was broken since the redesign.
- HTML entities are now correctly escaped and unescaped in ticket and reply content.

### Security
