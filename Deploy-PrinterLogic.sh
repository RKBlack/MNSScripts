#!/bin/bash
sudo -i
if ! [ -f /tmp/PrinterInstallerClientSetup.pkg ]; then
curl -o /tmp/PrinterInstallerClientSetup.pkg "https://$1/client/setup/PrinterInstallerClientSetup.pkg"
sleep 10
fi
installer -allowUntrusted -pkg /tmp/PrinterInstallerClientSetup.pkg -target /
bash /opt/PrinterInstallerClient/bin/set_home_url.sh https "$1"
bash /opt/PrinterInstallerClient/bin/use_authorization_code.sh "$2"
