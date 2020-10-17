[![Maintenance](https://img.shields.io/badge/Maintained-yes-green.svg)]() [![Powered by](https://img.shields.io/badge/ubuntu-v16.04-blue.svg)]() [![Docker](https://img.shields.io/badge/DockerImage-v1.0.1-green.svg)](https://hub.docker.com/repository/docker/benchaliah/poseidondns)

## Disclaimer

This tutorial is for informational and educational purposes only. I believe that ethical hacking, information security and cyber security should be familiar subjects to anyone using digital information and computers. And I urge anyone who would use this tool to only use it on targets he/she is authorized to access, I hold no responsability in one used it for any unlawful activity.


## About

* This is a tool that offers a cross-platform (Android, Windows, iOS ... etc) Remote and automated penetration, can be used for massive automated social engineering, randomware or more advanced pentests


[DNS hijacking](https://en.wikipedia.org/wiki/DNS_hijacking) is often used for phishing, in order to obtain sensitive information such as credentials for social media and bank accounts, but more advanced exploitation allows for more critical access. Let take the following scenario for instance, if a hacker gain access to the DNS settings in a router, he can in theory then control the entire flow of the target's internet connections, therefore, he can install malwares on the target's devices (smartphone, computer) using social engineering (fake updates, because normal updates done automatically by windows, android or otherwise are almost exlucsivly done via SSL which would require a signed certificate) or some vulnerability in the software already installed on the target's device. However, this process require investing significant time analyzing each target indivually and trying to gain more access.


## Approach

One of ways this tools can be used in, is using Nmap to scan massive IP ranges looking for routers that are exposed to WAN, most of them usually still hold the default login (example: user=admin pass=admin) then changing the DNS address in the DHCP settings, this process can be easily automated using a simple Python script and by using http requests or a Browser automation library (example: Selenium/Chromedriver-FirefoxDriver) you can automatically gain access to thousands of routers, there is also [Shodan](http://shodan.io) that can offer huge numbers of active IPs of routers that are exposed and you can even uses more filters to get only routers that uses a specific firmware/version on which you have a way to access even without default credentials (example : Millions of routers around the world uses Rompager/4.07 a firmware that have a critical vulnerability called [Misfortune Cookie](https://github.com/BenChaliah/MIPS-CVE-2014-9222)).
However, setting thousands of routers towards your DNS similtanously raises another question, how much resources would the server require? The server must respond to the millions of requests each minutes withing few miliseconds for each request, so that the targets wouldn't notice a difference in latency in their internet connection, one of the tools known in the cyber security community for DNS hijacking called DNSChef, a tool that is built on python, which makes it very useful in the case of small sample testing but highly unreliable when you test it against much bigger samples giving high failure rate. On the other hand there's dnsmasq which is written in C (making it much much faster with very little resources) and it offers DNS caching, a DHCP server and more. But since it was not intended for DNS Hijacking it's not quite configurable for such use.

However, in this analyzis I'll be explain how did I used it and other low level tools to make a server that even with very low specs (Example : Elastic computer hosted on AWS or gCloud 1 vcpu, 1Gb of memory) can offer for a huge number of targets a very low latency that compares to that of known public DNS such as `8.8.8.8`, or even supersede it depending on the location of the server and the targets.


