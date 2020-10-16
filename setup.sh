#!/bin/bash



if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root" 
	exit 1
fi

docker build -t poseidon .
docker run -it  --privileged --cap-add=ALL -v /lib/modules:/lib/modules -p 81:80 -p 5353:53 poseidon