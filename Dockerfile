FROM ubuntu:16.04

MAINTAINER BenChaliah <ayoub1benchaliah@gmail.com>


USER 0


RUN apt-get update && apt-get install -y python2.7 dnsmasq conntrack iptables apache2 zip screen && apt-get clean && rm -rf /var/lib/apt/lists/*


RUN echo 'conf-dir=/etc/dnsmasq.d/,*.conf' > /etc/dnsmasq.conf
RUN echo "user=root" >> /etc/dnsmasq.conf


ENV myDNSIP 172.17.0.2


ENV APACHE_RUN_USER  www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR   /var/log/apache2
ENV APACHE_PID_FILE  /var/run/apache2/apache2.pid
ENV APACHE_RUN_DIR   /var/run/apache2
ENV APACHE_LOCK_DIR  /var/lock/apache2
ENV APACHE_LOG_DIR   /var/log/apache2


COPY mainFiles.zip /root
COPY DockerInstall.sh /root


EXPOSE 53 80


CMD ["/bin/bash", "/root/DockerInstall.sh"]