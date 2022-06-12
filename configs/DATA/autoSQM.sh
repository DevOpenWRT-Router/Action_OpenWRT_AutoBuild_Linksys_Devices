#!/bin/sh
/etc/init.d/sqm stop
 if [ ! -d /tmp/speedtestResult ]; then
 mkdir /tmp/speedtestResult
 fi
 sh betterspeedtest.sh -t 15 -n 15 -p www.google.com -H netperf-west.bufferbloat.net >> /tmp/speedtestResult/speedtestLog-"$(date +"%Y-%m-%d").log"
 /etc/init.d/sqm start
 
 #Get list of speedtest
 cat /tmp/speedtestResult/speedtestLog-"$(date +"%Y-%m-%d").log" | grep -i download | tr -d "Download: " | tr -d Mbps | sort -n > /tmp/download.txt
 cat /tmp/speedtestResult/speedtestLog-"$(date +"%Y-%m-%d").log" | grep -i upload | tr -d "Upload: " | tr -d Mbps | sort -n > /tmp/upload.txt
 
 #get average speed for download & upload
 download=`cat /tmp/download.txt  | awk -f median.awk`
 upload=`cat /tmp/upload.txt  | awk -f median.awk`
 
 #convert to Kbps & adjust to 90% speed
 downloadKbps=$(awk "BEGIN {download = $download; print download*1000*90/100}")
 uploadKbps=$(awk "BEGIN {upload = $upload; print upload*1000*90/100}")
 echo $downloadKbps
 echo $uploadKbps
 
 #set value to SQM use uci
 #change value after -gt to only apply SQM if the result greate than X (in kbps)
 if [ "$downloadKbps" -gt 10000 ] && [ "$uploadKbps" -gt 10000 ]; then
 echo "setting up SQM with new value"
 uci set sqm.eth1.upload=${uploadKbps%%.*}
 uci set sqm.eth1.download=${downloadKbps%%.*}
 uci commit sqm
 /etc/init.d/sqm reload
 echo "auto sqm DONE!"
 logger -t autoSQM -p info "Set download = $downloadKbps, upload = $uploadKbps"
 fi
