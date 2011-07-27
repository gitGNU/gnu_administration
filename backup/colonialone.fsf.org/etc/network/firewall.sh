#!/bin/bash
# Copy/paste your own firewall!
# Copyright (C) 2005, 2006, 2007  Cliss XXI
# Copyright (C) 2007  Sylvain Beucler
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# Author: Sylvain Beucler <beuc@beuc.net>

# Quick install:
#  cp basic-firewall.txt /etc/network/if-pre-up.d/firewall
#  chmod 755 /etc/network/if-pre-up.d/firewall

# Alternative (only run once even if there are several interfaces):
#  cp basic-firewall.txt /etc/network/firewall.sh
#  chmod 755 /etc/network/firewall.sh
#  ---
#  iface eth0 inet static
#   ...
#   pre-up /etc/network/firewall.sh


# Clean-up
# Use 'ACCEPT' by default - safer when using '-F' manually
iptables -F
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

# Table 'nat' clean-up
iptables -t nat -F
iptables -t nat -P PREROUTING ACCEPT
iptables -t nat -P POSTROUTING ACCEPT
iptables -t nat -P OUTPUT ACCEPT


# Base
# Accept client-originated, loopback, ping and ssh connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p tcp --dport ssh -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT
# Or if you want to try to prevent ping DoS:
#iptables -A INPUT -p icmp -m icmp --icmp-type 8 -m limit --limit 10/sec -j ACCEPT

# SSH for root (backup during iptables hazardous manipulations)
iptables -A INPUT -p tcp --dst 140.186.70.51 --dport 24 -j ACCEPT
# SMTP from fsf office:
iptables -A INPUT -p tcp --src 199.232.76.163 --dport 25 -j ACCEPT
iptables -A INPUT -p tcp --src 66.92.78.210 --dport 25 -j ACCEPT
## SNMP
# SNMP traffic from fsf office
iptables -A INPUT -p udp --src 199.232.76.163 --dport 161 -j ACCEPT
iptables -A INPUT -p udp --src 66.92.78.210   --dport 161 -j ACCEPT
iptables -A INPUT -p udp --src 199.232.41.14  --dport 161 -j ACCEPT
iptables -A INPUT -p udp --src 199.232.76.172 --dport 161 -j ACCEPT
# Munin (Munin does source IP checking itself)
iptables -A INPUT -p tcp --dport 4949 -j ACCEPT

# DRBD with fsffrance
#iptables -A INPUT -p tcp --src 87.98.128.95 --dport 7788 -j ACCEPT

# Accept all traffic from internal nic
iptables -A INPUT -i eth0 -j ACCEPT

# OpenVPN
iptables -A INPUT -s 199.232.41.3 -p udp --dport openvpn -j ACCEPT
# Chapters
iptables -A INPUT -s 91.121.9.110 -p udp --dport openvpn -j ACCEPT

# Accept all traffic from OpenVPN
#iptables -A INPUT -i tun+ -j ACCEPT
iptables -A INPUT -i tap+ -j ACCEPT
iptables -A INPUT -i br-in -j ACCEPT

# Blacklist Bing, Microsoft's beta search engine, which does not
# respect robots.txt, and causes a high load.
# Enabled on 2009-09-02, still necessary as of 2009-09-14
iptables -I INPUT 1 -s 65.52.0.0/14 -j DROP
iptables -I INPUT 1 -s 65.55.0.0/14 -j DROP
iptables -I FORWARD 1 -s 65.52.0.0/14 -j DROP
iptables -I FORWARD 1 -s 65.55.0.0/14 -j DROP

# Blacklist 123.53.127.15 from China who apparently sent a bot
iptables -I FORWARD 1 -s 123.53.127.15/32 -j DROP

# Reject connections via rsh, so that people get immediate error when
# they forget to set CVS_RSH
iptables -A INPUT -p tcp --dport 514 -j REJECT --reject-with icmp-proto-unreachable

# Restrict to Beuc during tests
#iptables -A INPUT -s ! 82.238.35.175 -d 199.232.41.69 -j DROP
#iptables -A INPUT -s ! 82.238.35.175 -d 140.186.70.72 -j DROP

# Shared Internet access
# echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
# Modules ip_nat_ftp ip_conntrack_ftp ip_nat_irc ip_conntrack_irc
#         ip_conntrack_netbios_ns ip_conntrack_netlink
# -i forbidden in POSTROUTING
iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
# Need to masquerade local->public connections to too)
iptables -t nat -A POSTROUTING -s 10.1.0/24 -d 140.186.70.70/24 -j MASQUERADE
# Allowed routing
#iptables -A FORWARD -i tun+ -j ACCEPT
iptables -A FORWARD -i tap+ -j ACCEPT  # OpenVPN with GNU Chapters
#iptables -A FORWARD -j ACCEPT
#iptables -A FORWARD -s 10.1.0.0/24 -o eth1 -j ACCEPT
iptables -A FORWARD -i br-in -j ACCEPT
iptables -A FORWARD -o br-in -j ACCEPT
iptables -A FORWARD -i eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT


# Test:
#iptables -t nat -A PREROUTING -d 140.186.70.70 -p tcp --dport ssh   -j DNAT --to-destination 10.1.0.106
#iptables -t nat -A OUTPUT     -d 140.186.70.70 -p tcp --dport ssh   -j DNAT --to-destination 10.1.0.106
#iptables -A FORWARD --dst 10.1.0.106 -p tcp --dport 22 -o eth1 -j ACCEPT

# - sftp
iptables -t nat -A PREROUTING -d 140.186.70.73 -p tcp --dport ssh   -j DNAT --to-destination 10.1.0.105
iptables -t nat -A OUTPUT     -d 140.186.70.73 -p tcp --dport ssh   -j DNAT --to-destination 10.1.0.105
iptables -t nat -A PREROUTING -d 140.186.70.73 -p tcp --dport http  -j DNAT --to-destination 10.1.0.105
iptables -t nat -A OUTPUT     -d 140.186.70.73 -p tcp --dport http  -j DNAT --to-destination 10.1.0.105
iptables -t nat -A PREROUTING -d 140.186.70.73 -p tcp --dport rsync -j DNAT --to-destination 10.1.0.105
iptables -t nat -A OUTPUT     -d 140.186.70.73 -p tcp --dport rsync -j DNAT --to-destination 10.1.0.105
iptables -t nat -A PREROUTING -d 140.186.70.73 -p tcp --dport 8000  -j DNAT --to-destination 10.1.0.105
iptables -t nat -A OUTPUT     -d 140.186.70.73 -p tcp --dport 8000  -j DNAT --to-destination 10.1.0.105

# - vcs-noshell
iptables -t nat -A PREROUTING -d 140.186.70.72 -p tcp --dport ssh        -j DNAT --to-destination 10.1.0.108
iptables -t nat -A OUTPUT     -d 140.186.70.72 -p tcp --dport ssh        -j DNAT --to-destination 10.1.0.108
iptables -t nat -A PREROUTING -d 140.186.70.72 -p tcp --dport cvspserver -j DNAT --to-destination 10.1.0.108
iptables -t nat -A OUTPUT     -d 140.186.70.72 -p tcp --dport cvspserver -j DNAT --to-destination 10.1.0.108
iptables -t nat -A PREROUTING -d 140.186.70.72 -p tcp --dport http       -j DNAT --to-destination 10.1.0.108
iptables -t nat -A OUTPUT     -d 140.186.70.72 -p tcp --dport http       -j DNAT --to-destination 10.1.0.108
iptables -t nat -A PREROUTING -d 140.186.70.72 -p tcp --dport rsync      -j DNAT --to-destination 10.1.0.108
iptables -t nat -A OUTPUT     -d 140.186.70.72 -p tcp --dport rsync      -j DNAT --to-destination 10.1.0.108
iptables -t nat -A PREROUTING -d 140.186.70.72 -p tcp --dport git        -j DNAT --to-destination 10.1.0.108
iptables -t nat -A OUTPUT     -d 140.186.70.72 -p tcp --dport git        -j DNAT --to-destination 10.1.0.108
iptables -t nat -A PREROUTING -d 140.186.70.72 -p tcp --dport svn        -j DNAT --to-destination 10.1.0.108
iptables -t nat -A OUTPUT     -d 140.186.70.72 -p tcp --dport svn        -j DNAT --to-destination 10.1.0.108
iptables -t nat -A PREROUTING -d 140.186.70.73 -p tcp --dport 443        -j DNAT --to-destination 10.1.0.109
iptables -t nat -A OUTPUT     -d 140.186.70.73 -p tcp --dport 443        -j DNAT --to-destination 10.1.0.109
# git-cvspserver
iptables -t nat -A PREROUTING -d 140.186.70.73 -p tcp --dport cvspserver -j DNAT --to-destination 10.1.0.109
iptables -t nat -A OUTPUT     -d 140.186.70.73 -p tcp --dport cvspserver -j DNAT --to-destination 10.1.0.109
# bzr-hpss
iptables -t nat -A PREROUTING -d 140.186.70.72 -p tcp --dport 4155 -j DNAT --to-destination 10.1.0.108
iptables -t nat -A OUTPUT     -d 140.186.70.72 -p tcp --dport 4155 -j DNAT --to-destination 10.1.0.108
# git-cvspserver trick when sftp and vcs-noshell were on different boxes
#iptables -t nat -A POSTROUTING -d 10.1.0.109 -p tcp --dport cvspserver -j MASQUERADE

# - frontend
iptables -t nat -A PREROUTING -d 140.186.70.70 -p tcp --dport ssh        -j DNAT --to-destination 10.1.0.103
iptables -t nat -A OUTPUT     -d 140.186.70.70 -p tcp --dport ssh        -j DNAT --to-destination 10.1.0.103
iptables -t nat -A PREROUTING -d 140.186.70.70 -p tcp -m multiport --dports http,https -j DNAT --to-destination 10.1.0.103
iptables -t nat -A OUTPUT     -d 140.186.70.70 -p tcp -m multiport --dports http,https -j DNAT --to-destination 10.1.0.103
iptables -t nat -A PREROUTING -d 140.186.70.71 -p tcp -m multiport --dports http,https -j DNAT --to-destination 10.1.0.104
iptables -t nat -A OUTPUT     -d 140.186.70.71 -p tcp -m multiport --dports http,https -j DNAT --to-destination 10.1.0.104

# - internal
iptables -t nat -A PREROUTING -d 140.186.70.70  -p tcp --dport 8080 -j DNAT --to-destination 10.1.0.101
iptables -t nat -A OUTPUT     -d 140.186.70.70  -p tcp --dport 8080 -j DNAT --to-destination 10.1.0.101

# Reject everything else
# tcp-reset makes it look like as if there were no firewall
iptables -A INPUT -p tcp -j REJECT --reject-with tcp-reset
iptables -A INPUT -j REJECT

# Don't forward anything else
iptables -A FORWARD -j REJECT
