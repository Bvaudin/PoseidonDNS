import time, os


while True:
	try:
		os.system("cat $(ls -1t /var/www/cgi-bin/tmp/*.rules | head -1) | /sbin/iptables-restore")
		time.sleep(0.5)
	except Exception as e:
		print str(e)



