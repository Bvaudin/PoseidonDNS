import time, os



while True:
	try:
		rand_int = 35
		with open("/var/www/cgi-bin/rand_ref", "r") as f:
			rand_int = int(f.read())
		os.system("cd /var/www/cgi-bin/ips && find * -mmin +%d -exec  conntrack -D -s {} > /dev/null \\; && find * -mmin +%d -exec rm -f {} \\; && cd /root\n"%(rand_int,rand_int))
		time.sleep(0.5)
	except Exception as e:
		print str(e)



