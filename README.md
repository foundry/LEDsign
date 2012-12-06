__various code fragments for LED sign project__  

(c) jwm/foundry 2012  
code: BSD license (see LICENSE file)  
database: all rights reserved  
  

These code pieces are part of a live SMS Text -> LED signboard project  
Used in Tate Modern, powered by Raspberry Pi  

SMS -> USB modem -> SMS received database -> LED signboard  

**led\_db\_o.pl**  
Feeds an LED signboard with the contents of a database. Prioritises freshly received messages.

**LedSignOO.pm**  
Perl module to control the signboard. When I get the time I will post this to CPAN...
 
**test-db.sql**  
sample database

**smsd2.pl**  
USB modem keep-alive

Other code fragments to follow, this is a rough first commit.