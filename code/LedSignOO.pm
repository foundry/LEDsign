#!/usr/bin/perl -w

# /*
#  * Class for accessing compatible led signs
#  *
#  * php version 2008 (c) Juho Ojala
#  * perl port 2011 (c) jwm/foundry, s_how
#  * see LICENSE file for BSD license
#  */ 


# 	/*
# 	 * standard module header
# 	 */

package LedSignOO;

use strict;
use Exporter;
our ($VERSION, @ISA, @EXPORT, @EXPORT_OK);

$VERSION     = 1.00;
@ISA         = qw(Exporter);
@EXPORT      = ();

                 
use IO::Socket;

our %led_defaults = (
			ip => '81.187.231.27',
			port => 9520,
			sequence => 59
			);
sub new {
	my $class 	= shift;
	my  $self 	= {};
	    $self 	= {%led_defaults, @_};
	    bless     ($self, $class);
}
				
# 	/*
# 	 * Sets the text displayed on the Led Sign to
# 	 * $text. Accepts lot of special markup for changing
# 	 * colours, using transitions, multiple frames and so on.
# 	 */
	sub led_set_text {
		my $self = shift;
		my ($text,$simpleMoveLeft) = @_;
		my $cmd = $self->_get_text_command($text, $simpleMoveLeft);
		return $self->_send_command($cmd);
	}
	
# 	/*
# 	 * Initializes the Led Sign for use with the perl library.
# 	 */
	sub led_init {
		my $self = shift;
		my $cmd = $self->_get_sequent_sys_command();	
		my $success = $self->_send_command($cmd);
		$self->led_set_text('led_init ok');
	}
	
	sub led_blank {
		my $self = shift;
	    my $text="";
	    while (length($text) < 500) {
	    	$text .= " ";
	    }
		$self->led_set_text("$text");
	}
	
# 	/*
# 	 * Replaces curly brackets with regular ones
# 	 */
	sub led_replace_curly_brackets {
		my $self = shift;
		my $text = shift;
		$text =~ s/\{/\(/g;
		$text =~ s/\}/\)/g;
		return $text;	
	}
	

	
# 	/*
# 	 * Replaces special markup in $text with hex
# 	 * characters that the sign understands.
# 	 */
	sub _parse_text {
		my $self = shift;
		my $text = shift;
		my %replaceHash = (		
			'{blink}' => chr(0x07) . '1',
			'{/blink}' => chr(0x07) . '0',
		
			'{%m/%d/%C}' => chr(0x0b) . chr(0x20), 
			'{%d/%m/%C}' => chr(0x0b) . chr(0x21), 
			'{%m-%d-%C}' => chr(0x0b) . chr(0x22), 
			'{%d-%m-%C}' => chr(0x0b) . chr(0x23), 
			'{%m.%d.%C}' => chr(0x0b) . chr(0x24), 

			'{%C}' => chr(0x0b) . chr(0x25),
			'{%Y}' => chr(0x0b) . chr(0x26),
			
			'{%m}' => chr(0x0b) . chr(0x27), # month as number
			'{%b}' => chr(0x0b) . chr(0x28), # abbreviated month name
			'{%d}' => chr(0x0b) . chr(0x29), # day 01-31

			'{%u}' => chr(0x0b) . chr(0x2a), # weekday as decimal
			'{%a}' => chr(0x0b) . chr(0x2b), # abbreviated weekday 
			
			'{%H}' => chr(0x0b) . chr(0x2C),
			'{%M}' => chr(0x0b) . chr(0x2D),
			'{%S}' => chr(0x0b) . chr(0x2E),	
		
			'{%R}' => chr(0x0b) . chr(0x2F), # time on 24 hour notation
			'{%r}' => chr(0x0b) . chr(0x30), # time in am/pm notation

			'{celsius}' 	=> chr(0x0b) . chr(0x31), # temperature in celsius scale
			'{humidity}' 	=> chr(0x0b) . chr(0x32), # humidity
			'{fahrenheit}' 	=> chr(0x0b) . chr(0x33), # temperature in fahrenheit scale
			
			'{nf}' => chr(0x0c), # new frame
			'{nl}' => chr(0x0c), # new line

			'{left}' 	=> chr(0x1e) . '1', # align left
			'{center}' 	=> chr(0x1e) . '0', # center align
			'{right}' 	=> chr(0x1e) . '2', # align right

			'{halfspace}' => chr(0x82), # half space
			
			'{red}' 	=> chr(0x1c) . '1', # red
			'{green}' 	=> chr(0x1c) . '2', # green
			'{amber}' 	=> chr(0x1c) . '3', # amber/orange
			'{mixed1}' 	=> chr(0x1c) . '4', # amber-green-red pysty
			'{mixed2}' 	=> chr(0x1c) . '6', # 
			'{mixed4}' 	=> chr(0x1c) . '7', # 
		);
		
		# PHP
		#foreach ($replaceArray as $search => $replace) {
		#	$text = str_replace($search, $replace, $text);	
		#}
		# perl
		foreach my $search (keys %replaceHash) {
			$text =~ s/$search/$replaceHash{$search}/g;
		}
		
		# font size
		# PHP
  		# preg_match_all('/{f(\d)}/', $text, $matches, PREG_SET_ORDER);
  		# foreach ($matches as $match) {
 		#	$text = str_replace($match[0], chr(0x1a) . $match[1], $text);	
  		# }
		# perl
		$text =~ s/\{f(\d)\}/chr(0x1a)$1/g;

		# frame pause
		# PHP
  		# preg_match_all('/{p(\d\d?)}/', $text, $matches, PREG_SET_ORDER);
  		# foreach ($matches as $match) {
  		# 	if (strlen($match[1]) == 1) {
  		# 		$pauseTime = 0 . $match[1];	
  		# 	} else {
  		# 		$pauseTime = $match[1];	
  		# 	}
  		# 	$text = str_replace($match[0], chr(0x0e) . '0' . $pauseTime, $text);	
  		# }
		# perl
		$text =~ s/{p(\d\d)}/chr(0x0e)$1/g;
		$text =~ s/{p(\d)}/chr(0x0e)0$1/g;

		# display speed (speed of animation)
		# PHP
  		# preg_match_all('/{s(\d)}/', $text, $matches, PREG_SET_ORDER);
  		# foreach ($matches as $match) {
  		# 	$text = str_replace($match[0], chr(0x0f) . $match[1], $text);	
  		# }
		# perl
		$text =~ s/\{s(\d)\}/chr(0x0f)$1/g;
		
		# display modes (transitions)
		# PHP
		# $modes = self::_get_display_modes();
		# foreach ($modes as $key => $hexValue){
		# 	$chars = chr(0x0a) . 'I' . $hexValue;
		#	$text = str_replace('{' . $key .'In}', $chars , $text);
		# }
		# foreach ($modes as $key => $hexValue){
		#	$chars = chr(0x0a) . 'O' . $hexValue;
		#	$text = str_replace('{' . $key .'Out}', $chars , $text);
		#}
		# perl
		my $modesHashRef = $self->_get_display_modes();
		foreach my $mode (keys %$modesHashRef) {
			my $chars = chr(0x0a) . 'I' . $$modesHashRef{$mode};
			$text =~ s/\{ $mode In \}/$chars/xg;
			$chars = chr(0x0a) . 'O' . $$modesHashRef{$mode};
		    $text =~ s/\{ $mode Out \}/$chars/xg;
		}
		
		# PHP
 		# preg_match_all('/{s(\d)}/', $text, $matches, PREG_SET_ORDER);
 		# foreach ($matches as $match) {
 		#	$text = str_replace($match[0], chr(0x0f) . $match[1], $text);	
 		# }
		# perl
		$text =~ s/\{s(\d)\}/chr(0x0f)$1/g;
		return $text;
	}
	
# 	/*
# 	 * Returns the command for setting the text displayed
# 	 * on the sign to $text
# 	 */
	sub _get_text_command{
		my $self = shift;
		my ($text,$simpleMoveLeft) = @_;
		my $commandsPrefix = chr(0x01) . "Z00" .chr(0x02). "A";		
		#$savePath = "A"; 
		my $savePath = chr(0x0f) . "ETAB";
		my $displayProtocol = chr(0x06);
			
		my $displayMode = $self->_get_display_mode_bytes($simpleMoveLeft);		
		my $colourSetting = $self->_get_colour_bytes('red');

		my $fontSize = chr(0x1a) . "1"; # 7x6, default
		my $end = chr(0x03);
		
		$text = "{jumpOutOut}{jumpOutIn}" . $text;
		$text = $self->_parse_text($text);
		
		my $cmd = $commandsPrefix
		     . $savePath
		     . $displayProtocol
		     . $displayMode
		     . $fontSize
		     . $text
		     . $end;
		return $cmd;
	}
	
	sub _send_command {
		my $self = shift;
		my $cmd = shift;
		my $sock = new IO::Socket::INET (
				PeerAddr => $self->{'ip'},
				PeerPort => $self->{'port'},
				Proto =>  "udp",
					);
		die "Could not create socket: $!\n" unless $sock;
		print $sock $cmd;
		close ($sock);
		return 1;
	}
		

	sub _get_colour_bytes {
		my $self = shift;
		my $colour = shift;
		
		my %colourNumbers = (
			'red' 		=> 1,
			'green' 	=> 2,
			'amber' 	=> 3,
			'mixed1' 	=> 4,  #amber-green-red pystysuunnassa
			'mixed2' 	=> 5,  #yellow-green-red by merkki merkiltä
			'mixed3' 	=> 6,  #random parts			
			'mixed4' 	=> 7
		);
				
		return chr(0x1c) . $colourNumbers{$colour};
	}

	sub _get_display_modes() {
		my $self = shift;
		my %modes = (
			'random' 		=> chr(0x2f),
			'jumpOut' 		=> chr(0x30),
			'moveLeft' 		=> chr(0x31),
			'moveRight' 	=> chr(0x32),
			'scrollLeft' 	=> chr(0x33),
			'scrollRight' 	=> chr(0x34),
			'moveUp' 		=> chr(0x35),
			'moveDown' 		=> chr(0x36),
			'scrollToLR' 	=> chr(0x37),
			'scrollUp'	 	=> chr(0x38),
			'scrollDown' 	=> chr(0x39),
			'foldFromLR' 	=> chr(0x3a),
			'foldFromUD' 	=> chr(0x3b),
			'scrollToUD' 	=> chr(0x3c),
			'shuttleFromLR' => chr(0x3d),
			'shuttleFromUD' => chr(0x3e),
			'peelOffL' 		=> chr(0x3f),
			'peelOffR' 		=> chr(0x40),
			'shutterFromUD' => chr(0x41),
			'shutterFromLR' => chr(0x42),
			'raindrops' 	=> chr(0x43),		
			'randomMosaic' 	=> chr(0x44),		
			'twinklingStars'=> chr(0x45),		
			'hipHop' 		=> chr(0x46),
			'radarScan' 	=> chr(0x47),
			'fanOut' 		=> chr(0x48),
			'fanIn' 		=> chr(0x49),
			'spiralR' 		=> chr(0x4a),
			'spiralL' 		=> chr(0x4b),
			'toFourCorners' 	=> chr(0x4c),
			'fromFourCorners' 	=> chr(0x4d),
			'toFourSides' 		=> chr(0x4e),		
			'fromFourSides' 	=> chr(0x4f),		
			'scrollOutFromFourBlocks' 		=> chr(0x50),		
			'scrollInToFourBlocks' 			=> chr(0x51),		
			'moveOutFromFourBlocks' 		=> chr(0x52),		
			'moveInToFourBlocks' 			=> chr(0x53),		
			'scrollFromUpperLeftSquare' 	=> chr(0x54),		
			'scrollFromUpperRightSquare' 	=> chr(0x55),		
			'scrollFromLowerLeftSquare' 	=> chr(0x56),	
			'scrollFromLowerRightSquare' 	=> chr(0x57),		
			'scrollFromUpperLeftSlanting' 	=> chr(0x58),		
			'scrollFromUpperRightSlanting' 	=> chr(0x59),	
			'scrollFromLowerLeftSlanting' 	=> chr(0x5a),		
			'scrollFromLowerRightSlanting' 	=> chr(0x5b),		
			'moveInFromUpperLeftCorner' 	=> chr(0x5c),		
			'moveInFromUpperRightCorner' 	=> chr(0x5d),		
			'moveInFromLowerRightCorner' 	=> chr(0x5e),		
			'moveInFromLowerRightCorner' 	=> chr(0x5f),		
			'growingUp' => chr(0x60),
		);
		return \%modes;	
	}

	sub _get_display_mode_bytes {
		my $self = shift;
	    #
	    # the most basic way to set scrolling
	    # scrolling only occurs if text is longer than lenght of display
	    # default is OFF
	    #
		my $simpleMoveLeft = shift;
		if ($simpleMoveLeft) {
			return chr(0x1b) . '0a';				
		}
		return chr(0x1b) . '0b';					
	}
	
	
# 	/*
# 	 * Constructs a message of the type that is used
# 	 * for uploading files to the sign. 
# 	 *
# 	 * It has a header with checksums, length bytes and 
# 	 * some additional bytes.
# 	 *
# 	 * This is currently used for uploading the SEQUENT.SYS file,
# 	 * but it could also be used for example for uploading a 
# 	 * new CONFIG.SYS.
# 	 *
# 	 * $length is the length of the actual file and $data contains
# 	 * the "command" for uploading the file. 
# 	 *
# 	 * This has been adapted from a Python implementation by 
# 	 * Michael Barton: http:#www.weirdlooking.com\/blog\/108
# 	 */
	sub _construct_message {
	my $self = shift;
	my ($data, $length)= @_;
	my (@command, @msg);
		$command[0] = 2;
		$command[1] = 2;
		$command[2] = 6;
		
	my 	$isResponse = 0;
				
		$msg[0] = $length % 256;
		$msg[1] = int($length / 256);
		$msg[2] = 0;
		$msg[3] = 0;
		$msg[4] = 1; # group address. kokeilisko 1
		$msg[5] = 1; # unit address. kokeilisko 1
		$msg[6] = $led_defaults{sequence} % 256;
		$msg[7] = int($led_defaults{sequence} / 256);
		$msg[8] = $command[0];
		$msg[9] = $command[1];
		$msg[10] = $command[2];
		$msg[11] = $isResponse;

		# PHP:
# 		for ($i = 12; $i < 12 + strlen($data); $i++) {
# 			 $msg[$i] = ord($data[$i - 12]);	
# 		}
		# perl:
	my 	@data = split(//, $data);
		foreach (@data) {
			push @msg, ord($_);
		}

		# PHP:
#		my $sum = array_sum($msg);
		# perl:
	my 	$sum = eval join '+', @msg;
		
	my 	$checksum1 = $sum % 256;
	my 	$checksum2 = int($sum / 256);
		$self->{'sequence'}++;
		
		# PHP:
# 		for (my $i = 0; $i < count($msg); $i++) {
# 			$chrMsg = $chrMsg . chr($msg[$i]);	
# 		}
		# perl:
	my 	$chrMsg;
		foreach (@msg) {
			$chrMsg .= chr($_);
		}

		
	my 	$message = 'U' . chr(0xa7) . chr($checksum1) . chr($checksum2) . $chrMsg;
		return $message;
	}
	
	
# 	/*
# 	 * Returns the command for uploading a playlist file
# 	 * (SEQUENT.SYS) that points to one item on the RAM partition.
# 	 *
# 	 * The playlist will point to the file E:\T\AB. Calls to the
# 	 * function led_set_text($text) modify that file.
# 	 */
	sub _get_sequent_sys_command {
		my $self = shift;
 		open (SQ_FILE, '<','SEQUENT.SYS') or die "couldn't open SEQUENT.SYS\n";
# 		#my $data = file_get_contents('SEQUENT.SYS', true);	
        my $sq_file=join"",<SQ_FILE>;
        close SQ_FILE;
		# The upload command starts with some metadata bytes.
		# After them comes to actual content of the file to
		# be uploaded
		my $commandPrefix = 
		"SEQUENT.SYS" .
		chr(0x00) .
		chr(length($sq_file) % 256) . # number of bytes in the file % 256
		chr( int (length($sq_file) / 256)) . # number of bytes in the file / 256
		chr(0x00) .
		chr(0x00) .

		chr(0x00) .
		chr(0x03) .
		chr(0x01) .
		chr(0x00) .
		
		chr(0x01) .						
		chr(0x00) .						
		chr(0x00) .						
		chr(0x00);
				
		my $fullCommand = $commandPrefix . $sq_file;
		return $self->_construct_message($fullCommand, length($sq_file));
	}
	
sub _string_to_hex {
	  my $self = shift;
      my $string = shift;
      $string =~ s/(.)/sprintf(" %02x",ord($1))/eg;
      return $string;
      }
      
1;
