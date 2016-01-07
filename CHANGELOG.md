# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## Brimir unreleased (to be announced)
### Added
- Automatic refresh of inbox when browser tab receives focus again.
- Internal notes can now be added to tickets.
- Right to left support for Farsi.
- Mobile menu fixes from @sapslaj.

### Changed

### Deprecated

### Removed

### Fixed
- Ticket detail pages of tickets with draft replies could generate errors after saving a draft.
- Replies can now be seen again by other agents when ticket is locked.

### Security

## Brimir 0.6.3 (2015-11-06)
### Added
- Incoming email address selection on new ticket screen. Allowing rules to be applied for manually created tickets.
- To/cc address now becomes visible as notified users for all incoming mails.
- User preference to disable quoting of original message in the reply form.

### Changed
- Signatures are added to new tickets again.
- Realigned sign in view.
- Customers can only see replies they were notified of, allowing replies to be used as internal communication between agents.
- Reply notifications are now sent to the same users as the last reply by default.

### Removed
- The undocumented Brimir plugin to embed a new ticket form was removed.

### Fixed
- Ordering of replies is now always chronologically, even when drafts were saved.
- Attachments saved with a draft will not cause problems anymore.
- Non-multi part HTML mails are now correctly recognized.
- Outgoing plain text notifications are now wrapped at 72 characters as well.

## Brimir 0.6.2 (2015-10-23)
### Changed
- Lines of plain text tickets or replies are now wrapped at 72 characters.
- The rule action to notify users now creates users if they don't exist yet.

### Fixed
- French translation was improved by @sapk.

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
