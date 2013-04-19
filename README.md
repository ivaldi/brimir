Brimir
======
Brimir is a simple helpdesk system that can be used to handle support requests
via incoming email. It is still under heavy development, but can be used in
production.

Incoming email
--------------
Incoming emails can be posted to the tickets url. A script like this should
work:

    $ cat /etc/aliases
    brimir: "|/bin/bash /etc/postfix/brimir.sh"

    $ cat /etc/postfix/brimir.sh 
    #!/bin/bash
    exec curl --data-urlencode message@- https://yourserver.com/tickets

License
-------
Brimir is licensed under the GNU Affero General Public License Version 3.
