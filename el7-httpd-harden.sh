#!/bin/bash
# By Andrew Fox
# For use with RHEL/CentOS 7

HTTPD=$(rpm -q httpd)
MOD_SSL=$(rpm -q mod_ssl)

if [ "$HTTPD" = "package httpd is not installed" ]; then
   echo "$HTTPD"
   exit 1
elif [ "$MOD_SSL" = "package mod_ssl is not installed" ]; then
   echo "$MOD_SSL"
   exit 1
else
   sed -i '351i ServerTokens Prod\nTraceEnable off' /etc/httpd/conf/httpd.conf
   # Cipher Suite based on https://mozilla.github.io/server-side-tls/ssl-config-generator/
   sed -i 's/SSLProtocol all -SSLv2/#SSLProtocol all -SSLv2\nSSLProtocol all -SSLv2 -SSLv3/g' /etc/httpd/conf.d/ssl.conf
   sed -i 's/SSLCipherSuite HIGH:MEDIUM:!aNULL:!MD5/#SSLCipherSuite HIGH:MEDIUM:!aNULL:!MD5\nSSLCipherSuite  ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!3DES:!MD5:!PSK/g' /etc/httpd/conf.d/ssl.conf
   sed -i 's/#SSLHonorCipherOrder on/SSLHonorCipherOrder on\nSSLCompression off/g' /etc/httpd/conf.d/ssl.conf
   sed -i 's/<VirtualHost _default_:443>/<VirtualHost _default_:443>\nHeader always set Strict-Transport-Security "max-age=15768000"/g' /etc/httpd/conf.d/ssl.conf
   echo "...Done."
   exit 0
fi
