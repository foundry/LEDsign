#! /usr/bin/perl -w

# (c) jwm/foundry 2012
# see LICENSE file for BSD license

use strict;
use warnings;
use LedSignOO;
use DBI;
my ($message_table, $range, $verbose);
my $big_message_table = "messages";
my $big_message_table_size = 37183;

my $published_message_table = "messages_published";
my $published_message_table_size = 1949;

if ($ARGV[0] ~~ "-pub") {
	 $message_table = $published_message_table;
	 $range = $published_message_table_size;
} elsif ($ARGV[0] ~~ "-all") {
	 $message_table = $big_message_table;
	 $range = $big_message_table_size;
} else {
   print 
"-pub => published messages only
-all => all messages\n";
         exit(0);
}

print "pid $$\n";

if ($ARGV[1] ~~ "-v") { $verbose = 1}

my $sign = LedSignOO->new();	
$sign->led_init();

$|++;  #stream output

my $i = 1;
while (1) {
	my $dbh = DBI->connect ("dbi:mysql:test", "root", "marabe11a")
			  or die $DBI::errstr;
	
	my $id = int(rand($range));
#  	my @row = $dbh->selectrow_array("SELECT message, date, time FROM $message_table WHERE message_id = $id");
# 	my $text =  $row[0];
# 	$text =~ s/ ?[\n\r] ?/ / if $text;
# 	my $date = $row[1];
# 	$date =~ s/(\d\d\d\d)-(\d\d)-(\d\d)/$3-$2-$1/ if $date;
# 	my $time = $row[2];
# 	$time =~ s/(\d\d:\d\d):00/$1/ if $time;
	
	
 	my ($text,$date,$time) = $dbh->selectrow_array("
 							SELECT message, date, time 
 							FROM $message_table 
 							WHERE message_id = $id
 							");
 	if (!$text) {next}
	$text =~ s/ ?[\n\r] ?/ /;  #strip returns
	
	our %replace;
	require "stop_list.pl"; 


	my $regex = join "|", keys %replace;
	$regex =~ s/_/ /g;
	$regex =~ s/-/\,/g;

	$regex = qr/$regex/;
	$text =~ s/($regex)/$replace{$1}/ig;



	$date =~ s/(\d\d\d\d)-(\d\d)-(\d\d)/$3-$2-$1/ if $date;  #format date
	$time =~ s/(\d\d:\d\d):00/$1/ if $time;  #format time
	$time =~ s/^00:00$// if $time;
	my $datetime  =  "$date" if $date;
	   $datetime .= " $time" if $time;
# 	if((length($text)>30)&&(length($text)<40)) {
# 	    print "$text\n";
# 		if (int(rand(5))~~1) {
# 			$sign->led_set_text($datetime,1);
# 		print "datetime\n";
# 			}
# 		my @words=split(" ", $text);
# 		my $temp;
# 		while(length($text)<20) {
# 		  $temp=$text;
# 		   $text .= shift(@words)." ";
# 		}
# 		$text = $temp;
# 		my $text2=join(" ",@words);		
# 		sleep 3;
# 		$sign->led_set_text("                    ",1);
# 		sleep 1;
# 		$sign->led_set_text($text,1);
# 		print "text\n";
# 		sleep 6;
# 		$sign->led_set_text("                    ",1);
# 		sleep 1;
# 		$sign->led_set_text($text2,1);
# 		print "text2\n";
# 		sleep 6;
# 		$sign->led_set_text("                    ",1);
# 		sleep 1;
# 	}
	if (length($text)>20) {
		$text = "$datetime   $text";
		if ($verbose) {print "$text\n"}
		#$text .= "                                                                                                    ";
		$sign->led_set_text($text,1);
		#$sign->led_set_text("                    ",1);
		my $pause =  int((length($text) / 12)+4);
		sleep $pause;
	} else {
	    if ($verbose) {print "$text\n"}
		sleep 1;
		if (int(rand(5))~~1) {
			$sign->led_set_text($datetime,1);
			sleep 3;
		}
		$sign->led_set_text("                    ",1);
		sleep 1;
		$sign->led_set_text($text,1);
		sleep 6;
		$sign->led_set_text("                    ",1);
		sleep 1;
	 }
	$i++;
}