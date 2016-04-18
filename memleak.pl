#!/usr/bin/perl -w
use strict;

if (scalar (@ARGV) != 1) {
    print "\nUsage: reboot.pl ip_address or host_name\n\n";
    exit;
}

my $host_ip = $ARGV[0];
my $reload = ".1.3.6.1.4.1.9.2.9.9.0 i 2";
my $memoryUsed = ".1.3.6.1.4.1.9.9.48.1.1.1.5.1";
my $memoryFree = ".1.3.6.1.4.1.9.9.48.1.1.1.6.1";
my $comunity = "YOUR COMMUNITY STRING";
my $timestamp = localtime;

#get Free memory
my $ciscoMemoryPoolFree = `/usr/bin/snmpget -v2c -c $comunity $host_ip $memoryFree`;
#get used memory
my $ciscoMemoryPoolUsed = `/usr/bin/snmpget -v2c -c $comunity $host_ip $memoryUsed`;
my $freeMem = (split / /, $ciscoMemoryPoolFree)[-1];
my $usedMem = (split / /, $ciscoMemoryPoolUsed)[-1];

my $percentiUsedMem = sprintf("%.2f",($usedMem*100)/($freeMem+$usedMem));
print "$timestamp Percent Memory Usage: $percentiUsedMem\n";

#If a percent of Used Memory greater than 64%, it'll reboot AP
if($percentiUsedMem > 64) {
     my $returncode = system("/usr/bin/snmpset -v2c -c $comunity $host_ip $reload");
     if($returncode != 0) {
         print "$timestamp Falied to reboot $host_ip!\n";
     } else {
         print "$timestamp Reboot Successful $host_ip.\n";
     }
}
