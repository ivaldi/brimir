Brimir
======
Brimir is a simple helpdesk system that can be used to handle support requests
via incoming email. It is still under heavy development, but can be used in
production.

Incoming email
--------------
Incoming emails can be posted to the tickets url. First make a script like this:

    #!/bin/bash
    exec curl --data-urlencode message@- https://yourbrimirurl.com/tickets
    
Save it in `/etc/postfix/brimir.sh` for example.

Next, create an alias in your `/etc/aliases` file like this:

    brimir: "|/bin/bash /etc/postfix/brimir.sh"

Now sending an email to brimir@yourmailserver.com should start curl and post 
the email to your brimir installation.

License
-------
Brimir is licensed under the GNU Affero General Public License Version 3.
