#!/usr/bin/perl

opendir(my $dir, ".");

my @files = readdir($dir);

@files = sort @files;

print "<html><head><meta http-equiv=\"refresh\" content=\"120\"></head><body style=\"background-image:url(bgcolor-rrd.jpg);\"><center><table border=1>";

my $host;
my $oldhost;
my $file;
my $time;

print "<tr><th align=center>Source</th><th>Time</th><th>Preview</th></tr>";

foreach $file (@files) {
   if($file =~ /\.png/) {
       
       $host = $file;
       $host =~ s/\.png//;
          if($host =~ /.*-day/) {
              $host =~ s/-day//;
              $time = "The last day";
          }
          if($host =~ /.*-hour/) {
              $host =~ s/-hour//;
              $time = "The last hour";
          }
          if($host =~ /.*-week/) {
              $host =~ s/-week//;
              $time = "The last week";
          }
          if($host =~ /.*-month/) {
              $host =~ s/-month//;
              $time = "The last month";
          }
          if($host =~ /.*-year/) {
              $host =~ s/-year//;
              $time = "The last year";
          }
#       next if($oldhost eq $host);
       print "<tr><td><a href=\"$file\">$host</a></td><td>$time</td><td><a href=\"$file\"><img src=$file></a><td></tr>\n";
       
       $oldhost = $host;
   }
}

print "</table></center></body></html>";
