**Brimir is no longer used and maintained by Ivaldi, so this repository is switched to archived mode on Github.**

Brimir [![Build Status](https://travis-ci.org/ivaldi/brimir.png)](https://travis-ci.org/ivaldi/brimir) [![Coverage Status](https://coveralls.io/repos/ivaldi/brimir/badge.png)](https://coveralls.io/r/ivaldi/brimir)
======
[Brimir](http://getbrimir.com/) is a simple helpdesk system that can be used to handle support requests
via incoming email. Brimir is currently used in production at [Ivaldi](http://ivaldi.nl/).

Installation
------------
Brimir is a rather simple Ruby on Rails application. The only difficulty in setting things up is how to get incoming email to work. See the next section for details.

Any Rails application needs a web server with Ruby support first. We use Phusion Passenger (`mod_rails`) ourselves, but you can also use Thin, Puma or Unicorn. Phusion Passenger can be installed for Nginx or Apache, you can chose wichever you like best. The installation differs depending on your distribution, so have a look at their [Nginx installation manual](https://www.phusionpassenger.com/documentation/Users%20guide%20Nginx.html) or their [Apache installation manual](https://www.phusionpassenger.com/documentation/Users%20guide%20Apache.html).

After setting up a webserver, you have to create a database for Brimir and modify the config file in `config/database.yml` to reflect the details. Set your details under the production section. We advise to use `adapter: postgresql` or `adapter: mysql2` for production usage, because those are the only two adapters and database servers we test. *If you plan to use MySQL, make sure you use utf8 as your charset and collation.*

Your server will need a JavaScript runtime supported by [execjs](https://github.com/rails/execjs). We recommend [Node.js](https://nodejs.org/). The Node.js packages shipped by your distribution should be sufficient for this application.  Install via `apt-get install nodejs` on Debian/Ubuntu or `yum install nodejs` on RHEL/CentOS.

Next up: configuring your outgoing email address and url. This can be set in `config/environments/production.rb` by adding the following lines *before* the keyword `end`:

    config.action_mailer.default_options = { from: 'brimir@yoururl.com' }

    config.action_mailer.default_url_options = { host: 'brimir.yoururl.com' }

Now install the required gems by running the following command if you want **PostgreSQL support**:

    bundle install --without sqlite mysql development test --deployment

Run the following command to install gems if you want **MySQL support**:

    bundle install --without sqlite postgresql development test --deployment

Generate a secret\_key\_base in the secrets.yml file:

    LINUX: sed -i "s/<%= ENV\[\"SECRET_KEY_BASE\"\] %>/`bin/rake secret`/g" config/secrets.yml
    MAC: sed -i "" "s/<%= ENV\[\"SECRET_KEY_BASE\"\] %>/`bin/rake secret`/g" config/secrets.yml

Next, load the database schema and precompile assets:

    bin/rake db:schema:load RAILS_ENV=production
    bin/rake assets:precompile RAILS_ENV=production

If you want to use LDAP, configure config/ldap.yml accordingly, then change the auth strategy in your application config in file config/application.rb:

    config.devise_authentication_strategy = :ldap_authenticatable

(Optional for LDAP) Last thing left to do before logging in is making a user and adding some statuses. You can do this by running:

    bin/rails console production
    u = User.new({ email: 'your@email.address', password: 'somepassword' }); u.agent = true; u.save!

Configuring Captcha's
---------------------
If you want to use recaptcha in production you have to go to
https://www.google.com/recaptcha, create your private and public keys and export these to your production environment, by running:

    export RECAPTCHA_SITE_KEY="[YOUR_KEY]"
    export RECAPTCHA_SECRET_KEY="[YOUR_KEY]"

Remove the recaptcha lines from config/secrets.yml if you don't want to use captcha's all together.

Updating
--------
First download the new code in the same directory by unpacking a release tarball or by running `git pull` (when you cloned the repo earlier). After updating code run the following commands to install necessary gem updates, migrate the database and regenerate precompiled assets.

    bundle install
    bin/rake db:migrate RAILS_ENV=production
    bin/rake assets:precompile RAILS_ENV=production

Don't forget to restart your application server (`touch tmp/restart.txt` for Passenger).

Customization
-------------
Some applicant level configuration can be set through `config/settings.yml`

Brimir is available in several languages. By default, it will use the locale corresponding to the user browser agent, if it was among the supported locales. If you want to change this and force certain locale, you can do that by setting:   `ignore_user_agent_locale: true`  in  `config/settings.yml`

Incoming email
--------------

Brimir features several hooks to receive incoming mail. These hook URLs are protected by a mail_key which can be retrieved with:

    rake secret:mail_key

Make sure you replace `{MAIL_KEY}` in the examples below with the output from the above command.

:warning: The mail_key is derived from the secret\_key\_base. Whenever you modify the latter in the secrets.yml file, you have to update the hook URLs as well!

### MTA Alias

Incoming emails can be posted to Brimir by use of `scripts/post-mail`. Create an alias in the `aliases` file of your MTA as follows:

    brimir: "|/bin/sh /path/to/your/brimir/repo/script/post-mail http://yoururl.com/post-mail/{MAIL_KEY}/tickets.json"

Now sending an email to brimir@yoururl.com should execute curl and post the email to your Brimir installation.

### Mailgun

On Mailgun, add the IP of the server running Brimir to the [IP whitelist](https://app.mailgun.com/app/account/security). Then copy your [private API key](https://app.mailgun.com/app/account/security) and either paste it after "mailgun_private_api_key:" in `config/secrets.yml` or set the `MAILGUN_PRIVATE_API_KEY` environment variable accordingly. Finally, [create a route](https://app.mailgun.com/app/routes) with action "store and notify" and assign the following URL to this action:

    http://yoururl.com/mailgun/{MAIL_KEY}/tickets.json

Since you are receiving mails via Mailgun now, you might want to use the same provider to send mails as well. This can be set in `config/environments/production.rb` by adding the following lines *before* the keyword `end`:

    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      port: 587,
      address: 'smtp.mailgun.org',
      user_name: 'postmaster@yoururl.com',
      password: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx-xxxxxxxx-xxxxxxxx'
    }

The above `address`, `user_name` and `password` are examples, you find the real ones on the Mailgun [domain details page](https://app.mailgun.com/app/domains). Also, for this to work you have to be at least on the ["Concept" billing plan](https://app.mailgun.com/app/account/settings).

Contributing
------------
We appreciate all contributions! If you would like to contribute, please follow these steps:
- Fork the repo.
- Create a branch with a name that describes the change.
- Make your changes in the branch.
- Submit a pull-request to merge your feature-branch in our master branch.

Localization
------------
English (en) is the primary and default locale which should always be up-to-date and contain all translation keys currently in use. To keep the other locale files up to date, use the `locales:completeness` task to diff the translation keys of all available locales against English. Here's a commented example:

```
$ rake locales:completeness
Diffing against default locale files (en.yml).

WARNING: `it.yml' does not exist    <-- available locale :it has no YAML file

--- config/locales/en.yml
+++ config/locales/de.yml
  - close                           <-- translation for :de missing
  - wait
  + prefer_plain_text               <-- superfluous translation in :de or key
  + created_at                          removed from :en by mistake
```

More translations are welcome! To work on a new language, say Esperanto (eo), simply copy English as a template and start working on it:

    cp config/locales/en.yml config/locales/eo.yml

Once finished and quality checked, make sure you add the new locale to `config.i18n.available_locales` in `config/application.rb`. To disable a no longer maintained locale, simply remove it from `config.i18n.available_locales`, but leave the locale file checked in for future reference.

Requested features
------------------
Some users have made requests for the following features. If you would like to contribute, you could add any of these.
- Allowing customers to update ticket status, with correct email notifications.
- Switchable property to support threads by using special tags in the subject line instead of relying on mail headers.
- Support for hosted incoming mail services (Sendgrid, Mandrill), possibly using griddler gem.
- Ability to sign in using a Single Sign On functionality based on Shared Token or JWT.
- Private note addition to tickets.
- Automated replies based on the current rule system.
- Adding knowledge base functionality.
- Set labels on the create ticket form.
- Assign tickets to groups of users
- When replying, select a response from pre-defined canned responses and modify to your needs
- TicketsController#create should limit access to IP and be user/pass protected
- Integration with OpsWeekly
- Social media integration such as FreshDesk and Zoho have (reply to requests via social media)
- Ticket creation api (and improving existing api)
- Ticket search that also searches in from field and replies.
- Mark tickets as duplicate, linking it to the duplicated ticket.
- Ability to rename tickets (change their subject).
- Improve rule form to allow only valid statuses (#150).
- Timed rules, such as re-assigning when no reply is added withing 24 hours (#203).
- Desktop notifications using web notifications (#218).
- Custom ticket statuses, all via database. (#217)
- IMAP or POP3 pull mechanism for new tickets. (#249)
- Notes field for customer account, to add info about them, such as website url.

License
-------
Brimir is licensed under the GNU Affero General Public License Version 3.
