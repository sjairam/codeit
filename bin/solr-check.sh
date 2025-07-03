#!/bin/bash

this_host=`/bin/hostname`

tooz="lts-prodops@calists.harvard.edu"
fromz="drsadmsr@${this_host}"

PID_file="/home/drs_search/solr/bin/solr-18280.pid"
targ_url="http://localhost:18280/solr/#"

status_code=`/bin/curl -o /dev/null -s -w "%{http_code}\n" $targ_url`

if [ -f $PID_file ]; then
  #  there's a PID file, so SOLR has not been shut down cleanly
  SOLR_PID=`/bin/cat ${PID_file}`
  if [ -d /proc/${SOLR_PID} ]; then
    #  there's an actual running SOLR process, i.e. it hasn't crashed and
    #   left behind a bogus PID file
    if [ "${status_code}" != "200" ]; then
      #  even though it's running, it's not responding correctly
      {
        echo "From: ${fromz}"
        echo "To: ${tooz}"
        echo "Subject: check SOLR instance on ${this_host}"
        echo
        echo "The SOLR instance on ${this_host} seems to be running, but is"
        echo "producing HTTP code ${status_code}; it might need a restart."
      } | /usr/lib/sendmail -t
    fi
  fi
fi
