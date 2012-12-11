#! /usr/bin/perl -w 

use strict;
use warnings;
use LedSignOO;
use DBI;
use POSIX;
my ($message_table, $verbose);
my $big_message_table = "messages";
#my $big_message_table_size = 37183;
my $published_message_table = "messages_published";
#my $published_message_table_size = 1949;
my $sms_message_table = "inbox";

if ($ARGV[0] ~~ "-pub") {
	 $message_table = $published_message_table;
} elsif ($ARGV[0] ~~ "-all") {
	 $message_table = $big_message_table;
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

    
my $txt = DBI->connect ("dbi:mysql:texts", "root", "marabella")
			  or die $DBI::errstr;
my $sms = DBI->connect ("dbi:mysql:sms_gammu", "root", "marabella")
              or die $DBI::errstr;
my $txt_range = $txt->selectrow_array("
					SELECT count(*) from $message_table
					");
my $sms_range = &get_sms_range;

my $i = 1;
while (1) {
	my ($id,$db);
	my $chance = ceil(rand(4));
	my $new_sms_range = &get_sms_range;
	my $diff = $new_sms_range - $sms_range;
	if ($diff <0) {
		 $sms_range = $new_sms_range;
	}
    elsif ($diff > 0){
      print "range diff: $diff\n";
       $id = ($new_sms_range - $diff + 1);
       $db="sms";
       $sms_range++;
    }
	elsif ($chance==3) {
		my $sms_range = $sms->selectrow_array("
								SELECT count(*) from $sms_message_table
								");
		$id = ceil(rand($sms_range));
		$db="sms";
	} elsif ($chance==4) {
	   $id = 0;
	   $db = "";
	} else {
		$id = ceil(rand($txt_range));
		$db = "txt";
 	}
 	&play_message ($id,$db);
	$i++;
}

sub play_message {  #database, id
   my ($id,$database) = @_;
   my ($text,$date,$time,$datetime);
   if ( $id == 0) {
   		$text = "TXTMEUP 07903 905708";
   		$datetime="";
   
   } elsif ( $database eq "sms") {
   		($text,$datetime) = $sms->selectrow_array("
								SELECT TextDecoded, ReceivingDateTime 
								FROM $sms_message_table 
								WHERE ID = $id
								");
   } else {
   		($text,$date,$time) = $txt->selectrow_array("
								SELECT message, date, time 
								FROM $message_table 
								WHERE message_id = $id
								");
   
   		$date =~ s/(\d\d\d\d)-(\d\d)-(\d\d)/$3-$2-$1/ if $date;  #format date
		$time =~ s/(\d\d:\d\d):00/$1/ if $time;  #format time
		$time =~ s/^00:00$// if $time;
	    $datetime  =  "$date" if $date;
	    $datetime .= " $time" if $time;
   }
  if ($text) {
   	 	$text = &clean_text($text);
    	&display ($datetime,$text,$verbose,$sign);
    } 
}

sub get_sms_range { 
   return $sms->selectrow_array("
					SELECT count(*) from $sms_message_table
					");
}

sub get_counter {
     my $counter_file = "counter.txt";
    
	open(FILE,"<$counter_file") or return (0);
	my $counter = <FILE>;
	close(FILE);
	return chomp($counter);
}

sub clean_text {
    my $text = $_[0];
	$text =~ s/ ?[\n\r] ?/ /;  #strip returns
	
	our %replace;
	require "stop_list.pl"; 
	my $regex = join "|", keys %replace;
	$regex =~ s/_/ /g;
	$regex =~ s/-/\,/g;

	$regex = qr/$regex/;
	$text =~ s/($regex)/$replace{$1}/ig;
    return $text;
}


sub display {
 my ($datetime,$text,$verbose,$sign) = @_;
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
}