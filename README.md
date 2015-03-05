Brimir [![Build Status](https://travis-ci.org/ivaldi/brimir.png)](https://travis-ci.org/ivaldi/brimir) [![Coverage Status](https://coveralls.io/repos/ivaldi/brimir/badge.png)](https://coveralls.io/r/ivaldi/brimir)
======
[Brimir](http://getbrimir.com/) is a simple helpdesk system that can be used to handle support requests
via incoming email. Brimir is currently used in production at [Ivaldi](http://ivaldi.nl/).

Installation
------------
Brimir is a rather simple Ruby on Rails application. The only difficulty in setting things up is how to get incoming email to work. See the next section for details.

Any Rails application needs a web server with Ruby support first. We use Phusion Passenger (`mod_rails`) ourselves, but you can also use Thin, Puma or Unicorn. Phusion Passenger can be installed for Nginx or Apache, you can chose wichever you like best. The installation differs depending on your distribution, so have a look at their [Nginx installation manual](https://www.phusionpassenger.com/documentation/Users%20guide%20Nginx.html) or their [Apache installation manual](https://www.phusionpassenger.com/documentation/Users%20guide%20Apache.html).

After setting up a webserver, you have to create a database for Brimir and modify the config file in `config/database.yml` to reflect the details. Set your details under the production section. We advise to use `adapter: postgresql` or `adapter: mysql2` for production usage, because those are the only two adapters and database servers we test.

Next up: configuring your outgoing email address and url. This can be set in `config/environments/production.rb` by adding the following lines *before* the keyword `end`:

    config.action_mailer.default_options = { from: 'brimir@yoururl.com' }

    config.action_mailer.default_url_options = { host: 'brimir.yoururl.com' }

Now install the required gems by running the following command if you want **PostgreSQL support**:

    bundle install --without sqlite mysql development test --deployment

Run the following command to install gems if you want **MySQL support**:

    bundle install --without sqlite postgresql development test --deployment

Generate a secret\_key\_base in the secrets.yml file:

    sed -i "s/<%= ENV\[\"SECRET_KEY_BASE\"\] %>/`bin/rake secret`/g" config/secrets.yml

Next, load the database schema and precompile assets:

    rake db:schema:load RAILS_ENV=production
    rake assets:precompile RAILS_ENV=production

If you want to use LDAP, configure config/ldap.yml accordingly, then change the auth strategy in the user model:

    def self.authentication_strategy
        :ldap_authenticatable
    end

(Optional for LDAP) Last thing left to do before logging in is making a user and adding some statuses. You can do this by running:

    bin/rails console production
    u = User.new({ email: 'your@email.address', password: 'somepassword', password_confirmation: 'somepassword' }); u.agent = true; u.save!

Incoming email
--------------
Incoming emails can be posted to the tickets url by using the script found in scripts/post-mail. Create an alias in your `/etc/aliases` file like this:

    brimir: "|/bin/bash /path/to/your/brimir/repo/script/post-mail http://yoururl.com/tickets.json"

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
- Allowing customers to update ticket status, with correct email notifications.
- Switchable property to support threads by using special tags in the subject line instead of relying on mail headers.
- Support for hosted incoming mail services (Sendgrid, Mandrill), possibly using griddler gem.
- Ability to sign in using a Single Sign On functionality based on Shared Token or JWT.
- Queue sorting by column header.
- Private note addition to tickets.
- Automated replies based on the current rule system.
- Closing issues from the overview page.
- Remove user functionality, without losing ticket and reply information.
- Adding knowledge base functionality.
- Welcome mail for new users (after mailing a ticket for example) with their password.
- Set priority, assignee and labels on the create ticket form.
- Assign tickets to groups of users
- When replying, select a response from pre-defined canned responses and modify to your needs
- TicketsController#create should limit access to IP and be user/pass protected
- TicketsController#new should be configurable as open-to-the-world or not
- Integration with OpsWeekly
- Social media integration such as FreshDesk and Zoho have (reply to requests via social media)
- Ticket creation api (and improving existing api)

License
-------
Brimir is licensed under the GNU Affero General Public License Version 3.
