#!/bin/bash

set -x

template_file=/usr/share/doc/sogo/sogo.conf
if [[ -e ${template_file} ]]
then
  cat ${template_file} | envsubst > /etc/sogo/sogo.conf
fi
if [[ -d /docker-entrypoint.d ]]
then
  cd /docker-entrypoint.d
  for i in *.sh
  do
    source $i
  done
fi
echo ========= /etc/sogo/sogo.conf =========
cat /etc/sogo/sogo.conf
echo =======================================
plparse /etc/sogo/sogo.conf
/usr/sbin/sogod -WONoDetach YES
