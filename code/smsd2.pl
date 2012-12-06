#! /usr/bin/perl -w

# (c) jwm/foundry 2012
# see LICENSE file for BSD license

# used for Tate LED signboard/modem/raspberryPI project
# tests that we have access to the USB Modem
# if we don't it reconnects
# then sets up a timing loop to periodically disconnect/reconnect
# this keeps the USB modem alive

use strict;
use feature qw(say);

my $USB_VENDOR ="12d1"; #Huawei Technologies Co., Ltd
my $USB_PRODUCT ="1001";  #E169/E620/E800 HSDPA Modem
my $PROCESS_NAME="gammu-smsd";
my $REFRESH_TIME = 60;
my $dead_pid = "";
my $PROCESS_ID = "";
`usb_modeswitch -R -W -v $USB_VENDOR -p $USB_PRODUCT`;
`/etc/init.d/$PROCESS_NAME start`;
my $time = time;
while (1) {
  $PROCESS_ID = `pgrep $PROCESS_NAME`;
  if (!$PROCESS_ID)  {
        say "starting server... ";
        `usb_modeswitch -R -W -v $USB_VENDOR -p $USB_PRODUCT`;
		`/etc/init.d/$PROCESS_NAME start`;
   	} 
   	elsif ( (time - $time) > $REFRESH_TIME || $dead_pid eq $PROCESS_ID ){
		#stop server
		say "stopping server... time:".(time - $time)." dead_pid:$dead_pid pid:$PROCESS_ID";
		`/etc/init.d/$PROCESS_NAME stop`;
		$time = time;
		$dead_pid = $PROCESS_ID;
 	} 
}

