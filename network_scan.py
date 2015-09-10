#!/usr/bin/env python
##############################################Network Scanner############################################
##############################################Author- Jagmohan Singh(B11062)############################################
####################################################- Rishabh Sahu(B11025)#####################################
###############################################Date-19 November 2014 ###########################################

from threading import Thread
import subprocess
from Queue import Queue

import socket, struct, fcntl
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sockfd = sock.fileno()
SIOCGIFADDR = 0x8915
def get_ip(iface = 'wlan0'):####################function to get the local ip for wireless
     ifreq = struct.pack('16sH14s', iface, socket.AF_INET, '\x00'*14)
     try:
              res = fcntl.ioctl(sockfd, SIOCGIFADDR, ifreq)
     except:
         return None
     ip = struct.unpack('16sH2x4s8x', res)[2]
     return socket.inet_ntoa(ip)
ip=get_ip('wlan0')####getting the ip
ip=ip.split('.')
ip=ip[0]+'.'+ip[1]+'.'+ip[2]+'.'####splitting the ip

num_threads = 20
queue = Queue()

#wraps system ping command
##function to check the status of node
def pinger(i, q):
    """Pings subnet"""
    while True:
    	fp=open("result.dat",'a')
        ip = q.get()
        print "Thread %s: Pinging %s" % (i, ip)
        ret = subprocess.call("ping -c 1 %s" % ip,
            shell=True,
            stdout=open('/dev/null', 'w'),
            stderr=subprocess.STDOUT)
        if ret == 0:
            print "%s: is alive" % ip
            fp.write(ip+"\n")
        else:
            print "%s: did not respond" % ip
        q.task_done()
#Spawn thread pool
###thread pools 
for i in range(num_threads):

    worker = Thread(target=pinger, args=(i, queue))
    worker.setDaemon(True)
    worker.start()
#Place work in queue
for i in range(0,256):
	ip1=ip+str(i)
	queue.put(ip1)
    
#Wait until worker threads are done to exit    
queue.join()