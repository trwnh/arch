#!/bin/bash

# nginx web
systemctl restart nginx
echo "Restarted nginx"

# quassel irc
cat /etc/letsencrypt/live/trwnh.com/{privkey.pem,fullchain.pem} > /srv/quassel/quasselCert.pem
chown -R quassel:quassel /srv/quassel/quasselCert.pem
systemctl restart quassel
echo "Done with Quassel"

# mumble voip
sudo cp /etc/letsencrypt/live/trwnh.com/fullchain.pem /srv/mumble/certs/fullchain.pem
sudo cp /etc/letsencrypt/live/trwnh.com/privkey.pem /srv/mumble/certs/privkey.pem
sudo chown -R mumble:mumble /srv/mumble
systemctl restart mumble
echo "Done with Mumble"

# prosody xmpp
/usr/bin/prosodyctl --root cert import /etc/letsencrypt/live
systemctl restart prosody
echo "Done with Prosody"

echo "All tasks successful!"