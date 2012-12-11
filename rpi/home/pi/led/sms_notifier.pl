#! /usr/bin/perl -w 


print "\a";
my $file = "counter.txt";

open(FILE,"$file"); 
my $counter = <FILE>;
close FILE;
chomp($counter);
$counter++;
open (FILE, ">$file");
print FILE "$counter"; 
close(FILE);
print "\a\a";
