Brimir [![Build Status](https://travis-ci.org/ivaldi/brimir.png)](https://travis-ci.org/ivaldi/brimir) [![Coverage Status](https://coveralls.io/repos/ivaldi/brimir/badge.png)](https://coveralls.io/r/ivaldi/brimir)
======
[Brimir](http://getbrimir.com/) is a simple helpdesk system that can be used to handle support requests
via incoming email. Brimir is currently used in production at [Ivaldi](http://ivaldi.nl/).

Installation
------------
Brimir is a rather simple Ruby on Rails application. The only difficulty in setting things up is how to get incoming email to work. See the next section for details.

To install brimir you first have to create a database and modify the config file in `config/database.yml` to reflect the details. Set your details under the production section. We advice to use `adapter: postgresql` or `adapter: mysql2` for production usage, because those are the only two adapters and database servers we test.

Next up: configuring your outgoing email address and url. This can be set in `config/environments/production.rb` by adding the following lines *before* the keyword `end`:

    ActionMailer::Base.default :from => 'brimir@yoururl.com'
	config.action_mailer.default_url_options = { :host => 'brimir.yoururl.com' }

Now install the required gems by running:

    bundle install --without development:test --deployment

Next, load the database schema and precompile assets:

    rake db:schema:load RAILS_ENV=production
    rake assets:precompile RAILS_ENV=production

Last thing left to do before logging in is making a user and adding some statuses. You can do this by running:

    rails console
    u = User.new({ email: 'your@email.address', password: 'somepassword', password_confirmation: 'somepassword' }); u.agent = true; u.save!

Incoming email
--------------
Incoming emails can be posted to the tickets url by using the script found in scripts/post-mail. Create an alias in your `/etc/aliases` file like this:

    brimir: "|/bin/bash /path/to/your/brimir/repo/scripts/post-mail yoururl.com"

Now sending an email to brimir@yoururl.com should start curl and post the email to your brimir installation.

Contributing
------------
We appreciate all contributions! If you would like to contribute, please follow these steps:
- Fork the repo.
- Create a branch with a name that describes the change.
- Make your changes in the branch.
- Submit a pull-request to merge your feature-branch in our master branch.

Requested features
------------------
Some users have made requests for the following features. If you would like to contribute, you could add any of these.
- Switchable property to support threads by using special tags in the subject line instead of relying on mail headers.
- Grouping issues by project.
- Support for hosted incoming mail services (Sendgrid, Mandrill), possibly using griddler gem.

License
-------
Brimir is licensed under the GNU Affero General Public License Version 3.
