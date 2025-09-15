#!/bin/bash

template_file=/usr/share/doc/sogo/sogo.conf
if [[ -e ${template_file} ]]
then
  cat ${template_file} > /etc/sogo/sogo.conf
fi
if [[ -d /docker-entrypoint.d ]]
then
  cd /docker-entrypoint.d
  for i in *.sh
  do
    source $i
  done
fi
/usr/sbin/sogod -WOWorkersCount 3 -WOLogFile /dev/stdout -WONoDetach YES
