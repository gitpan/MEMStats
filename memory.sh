#!/bin/sh

if [ ! $1 ]; then
    echo "no host given!"
    exit 0
fi

snmpapp=`which snmpwalk`
password=my_secret_snmp_password
host=$1
rrdapp=`which rrdtool`

TotalReal=`$snmpapp $host $password enterprises.ucdavis.memory.memTotalReal.0 | sed -e 's/.*=\ //g'`
AvailReal=`$snmpapp $host $password enterprises.ucdavis.memory.memAvailReal.0 | sed -e 's/.*=\ //g'`

TotalSwap=`$snmpapp $host $password enterprises.ucdavis.memory.memTotalSwap.0 | sed -e 's/.*=\ //g'`
AvailSwap=`$snmpapp $host $password enterprises.ucdavis.memory.memAvailSwap.0 | sed -e 's/.*=\ //g'`

UsedReal=`echo $TotalReal $AvailReal | awk '{print $1 - $2}'`
UsedSwap=`echo $TotalSwap $AvailSwap | awk '{print $1 - $2}'`

$rrdapp update $host.rrd N:$TotalReal:$UsedReal:$TotalSwap:$UsedSwap
