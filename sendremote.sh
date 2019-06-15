#!/bin/bash
ssh -t root@109.105.116.20 -p 6667 "sudo /bin/systemctl start squid"
