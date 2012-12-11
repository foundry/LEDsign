__various code fragments for LED sign project__  
Gammu code: GNU GPL2 License

Other code: BSD license (see LICENSE file)  
(c) jwm/foundry 2012  
database: all rights reserved  
  
These code pieces are part of a live SMS Text -> LED signboard project  
Used in Tate Modern, powered by Raspberry Pi  

SMS -> USB modem -> SMS received database -> LED signboard  

NB - this setup uses Gammu. Others might find Gnokii better or worse..

**/pi_notes.txt**  

	- various unedited jottings about setting up the raspberry pi and peripherals

**/usr/bin/gammu-smsd**  

	- Gammu sms daemon 
	- gets new sms messages from the modem SIM card 
	- inserts them into a mysql database
	- increments a notification counter
	
**/etc/gammu-smsdrc**    

	- config file for gammu-smsd
	
**/etc/init.d/gammu-smsd**  

	- start/stop bash script for gammu-smsd

**/#/home/pi/led/sms_notifier.pl**    
[unused - we are now counting database entries instead]  

	- perl script run whenever a new msg arrives (increments a counter)
	- invoked from gammu-smsdrc (RunOnReceive directive)
	

**/home/pi/led/led_db_o.pl**  

	- perl run from the commandline
	- takes messages from mysql database and passes them to the LED controller
	- compares message_count with previous_count. If there are new messages, shows them first, otherwise picks a random message.
	
**/home/pi/led/LedSignOO.pm**  

	- perl module, LED sign controller
	- LED needs to be from CHAINZONE (chinese OEM). In the UK the brand is Messagemaker
	
**/home/pi/led/SEQUENT.SYS**  

	- firmware used by LED sign, uploaded by LedSignOO.pm
	
**/home/pi/led/test-db.sql**  

	- sample database

**smsd2.pl**  

	- USB modem keep-alive

