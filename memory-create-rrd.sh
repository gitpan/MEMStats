#!/bin/sh

rrdapp=`which rrdtool`

filename=$1

$rrdapp create $filename.rrd --start 0 --step 60 DS:mtotal:GAUGE:100:U:U \
                                         DS:mused:GAUGE:100:U:U \
                                         DS:stotal:GAUGE:100:U:U \
                                         DS:sused:GAUGE:100:U:U \
                                         RRA:AVERAGE:0.5:1:70 \
                                         RRA:AVERAGE:0.5:2:750 \
                                         RRA:AVERAGE:0.5:15:650 \
                                         RRA:AVERAGE:0.5:50:650;
