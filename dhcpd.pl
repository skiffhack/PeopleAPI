#!/usr/bin/env perl
use strict;
use POE;
use POE::Component::DHCP::Monitor;
use Net::DHCP::Packet;

$|=1;

POE::Session->create(
  inline_states => {
    _start              => \&_start,
    dhcp_monitor_packet => \&dhcp_monitor_packet,
    _default            => \&_default,
  },
);

$poe_kernel->run();
exit 0;

sub _start {
  my ($kernel,$heap) = @_[KERNEL,HEAP];
  $heap->{monitor} = 
  POE::Component::DHCP::Monitor->spawn(
    alias => 'monitor',       # optional
    port1  => 67, 		  # default shown
    port2  => 68,		  # default shown
    #address => '192.168.1.1', # default is INADDR_ANY
  );
  return;
}

sub dhcp_monitor_packet {
  my ($kernel,$heap,$packet) = @_[KERNEL,HEAP,ARG0];
  print STDOUT $packet->toString();
  print STDOUT "=============================================================================\n";
  return;
}

sub _default {
   my ($event, $args) = @_[ARG0 .. $#_];
   my @output = ( "$event: " );

   for my $arg (@$args) {
       if ( ref $arg eq 'ARRAY' ) {
           push( @output, '[' . join(', ', @$arg ) . ']' );
       }
       else {
           push ( @output, "'$arg'" );
       }
   }
   print join ' ', @output, "\n";
   return;
}