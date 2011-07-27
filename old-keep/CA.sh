#!/bin/bash
# Maintenance script for SSL certificates
# Copyright (C) 2006  Sylvain Beucler
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

# TODO:
# - Use GnuTLS instead of openssl if possible
#   -check http://www.gnu.org/software/gnutls/manual/gnutls.html#Invoking-certtool
# - Make 1 call to 'openssl ca' to issue several certificates at once, if possible
# - There's a way for ssl to get the information from a file, instead of stdin

ca_dir=~/tls
apache_conf_dir=/vservers/savannah/etc/apache
web_dir=/vservers/savannah/var/www/tls

umask 0077 # sensitive data generated here

if [ ! -e $apache_conf_dir ]; then
    echo "Apache dir $apache_conf_dir does not exist."
    exit 1
fi

function create_CA_base {
    if [ -e $ca_dir ]; then
	echo "CA dir $ca_dir already exists."
	exit 1
    fi

    mkdir -m 700 $ca_dir
    mkdir -m 700 $ca_dir/demoCA
    echo "This is the openssl hierarchy we used to make the `date +%Y` certificates for https" > $ca_dir/README
    cd $ca_dir/demoCA
    mkdir -m 755 newcerts
    mkdir -m 700 private
    echo "01" > serial
    touch index.txt
}

function output_default_information {
    CN=${1:-Savannah Hackers}
    echo "US"       # Country Name (2 letter code) [AU]:
    echo "MA"       # State or Province Name (full name) [Some-State]:
    echo "Boston"   # Locality Name (eg, city) []:
    echo "FSF"      # Organization Name (eg, company) [Internet Widgits Pty Ltd]:
    echo "Savannah" # Organizational Unit Name (eg, section) []:
    echo "$CN"      # Common Name (eg, YOUR name) []:
    echo "savannah-hackers-public@gnu.org" # Email Address []: 
}


if [ x"$1" = x"createCA" ]
then

    create_CA_base

    cd $ca_dir/demoCA
    echo "CA root key passphrase:"
    output_default_information \
	| openssl req -new -x509 -days 365 -keyout private/cakey.pem -out cacert.pem \
	2> /dev/null

    exit 0

elif [ x"$1" = x"recreateCA" ]
# ~/tls was accidentaly removed, let's recreate it out of the apache dir
then
    create_CA_base

    cd $ca_dir/demoCA

    # "100" so we won't confuse with the existing certificates. Should
    # be done more cleanly.
    echo "100" > serial
    echo "Configure $ca_dir/demoCA/serial appropriately"

    cp -a $apache_conf_dir/ssl.key/ca.key private/cakey.pem
    cp $apache_conf_dir/ssl.crt/ca.crt private/cacert.pem

    exit 0

elif [ x"$1" = x"renew" ]
then

    cd $ca_dir || exit 1
    
    for site in 'savannah.gnu.org' 'savannah.nongnu.org' 'cvs.*gnu.org'
      do
      $0 createcert "$site"
    done
    exit 0

elif [ x"$1" = x"createcert" ]
then

    cd $ca_dir || exit 1
    
    if [ -z "$2" ]; then
	echo "Usage: $0 createcert domain"
	exit 1
    fi

    site=$2
    # Password-less keys for Apache
    (output_default_information "$site"; echo; echo) \
	| openssl req -new -nodes -keyout "$site.key" -out "$site.csr" \
	2> /dev/null
    chmod 600 "$site.key"
    chmod 600 "$site.csr"

      # Certificate by our CA
    openssl ca -in "$site.csr" -out "$site.crt"

    exit 0

elif [ x"$1" = x"install" ]
then

    cd $ca_dir || exit 1

    install -m 600 demoCA/cacert.pem ca.crt
    install -m 600 demoCA/private/cakey.pem ca.key

    echo "Sign checksums.txt and copy/paste in your announcement"
    echo "gpg --clearsign --use-agent < checksums.txt > checksums-signed.txt"
    echo "cp checksums-signed.txt /vservers/savannah/var/www/tls/"
    (
	for i in *.crt; do
	    install -m 600 ${i%.crt}.key $apache_conf_dir/ssl.key/
	    install -m 644 $i $apache_conf_dir/ssl.crt/
	    install -m 644 $i $web_dir/

	    echo ${i%.crt}:
	    echo -n "* "
	    openssl x509 -fingerprint -sha1 -noout -in $i
	    echo -n "* "
	    openssl x509 -fingerprint -md5  -noout -in $i
	done
    ) > checksums.txt

    exit 0

else

    echo "Usage: $0 createCA|recreateCA|renew|createcert|install"
    exit 0

fi
