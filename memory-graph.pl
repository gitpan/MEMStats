#!/usr/bin/perl

use strict;
use warnings;
use POSIX qw(setsid);

sub write_png {
    my $time = shift;
    my $host = shift;

    my $out_file = $host."-$time.png";
    my $in_file  = $host.".rrd";
    
    my $common =  "rrdtool graph $out_file";
       $common .= " -u 100 -v '% utilization'";
       $common .= " DEF:mtotal=$in_file:mtotal:AVERAGE";
       $common .= " DEF:mused=$in_file:mused:AVERAGE";
       $common .= " DEF:stotal=$in_file:stotal:AVERAGE";
       $common .= " DEF:sused=$in_file:sused:AVERAGE";
       $common .= " CDEF:mmed=mused,100,*,mtotal,/";
       $common .= " CDEF:smed=sused,100,*,stotal,/";
       $common .= " COMMENT:'Type        Max      Min  Average\\n'";
       $common .= " LINE1:mmed#FF0000:'Memory'";
       $common .= " GPRINT:mmed:MAX:'%6.2lf'";
       $common .= " GPRINT:mmed:MIN:'%6.2lf'";
       $common .= " GPRINT:mmed:AVERAGE:'%6.2lf\\n'";
       $common .= " LINE2:smed#00FF00:'Swap  '";
       $common .= " GPRINT:smed:MAX:'%6.2lf'";
       $common .= " GPRINT:smed:MIN:'%6.2lf'";
       $common .= " GPRINT:smed:AVERAGE:'%6.2lf\\n'";
       $common .= " -h 100 -w 400";
       $common .= " -a PNG";
       $common .= " COMMENT:'\\n' COMMENT:\"Created: `date`\"";

    if($time eq "hour") {
        $common .= " --start -3600 --end -60 --title 'The last hour'";
    }
    if($time eq "month") {
        $common .= " --start -18748800 --end -60 --title 'The last month'";
    }
    if($time eq "day") {
        $common .= " --start -86400 --end -60 --title 'The last day'";
    }
    if($time eq "week") {
        $common .= " --start -604800 --end -60 --title 'The last week'";
    }
    if($time eq "year") {
        $common .= " --start -31536000 --end -60 --title 'The last year'";
    }
    system($common);
}

if($ARGV[0]) {
    my $host = $ARGV[0];

    if(-e "$host.lock") { print "$host is locked!"; exit 0 }
    unless(-e "$host.rrd") {
        print "no round robin database found!\n",
              "creating a new one.\n";
        system("./memory-create-rrd.sh $host");
    }
    print "Deamonizing now\nBye...\n";

    system("touch $host.lock");

    defined(my $pid = fork)   or die "Can't fork: $!";
    exit if $pid;
    setsid                    or die "Can't start a new session: $!";

    open STDIN, '/dev/null'   or die "Can't read /dev/null: $!";
    open STDOUT, '>>/dev/null' or die "Can't write to /dev/null: $!";
    open STDERR, '>>/dev/null' or die "Can't write to /dev/null: $!";

    while(1) {
        system("./memory.sh $host");

        &write_png("hour", $host);
        &write_png("day", $host);
        &write_png("week", $host);
        &write_png("month", $host);
        &write_png("year", $host);
        sleep 60;
    }
} else {
    print "not host given!";
    exit 0;
}
