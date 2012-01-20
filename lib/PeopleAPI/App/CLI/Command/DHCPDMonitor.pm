package PeopleAPI::App::CLI::Command::DHCPDMonitor;

use Moo;
use v5.14.1;
use PeopleAPI::App::CLI -command;
use POE;
use POE::Component::DHCP::Monitor;
use Net::DHCP::Packet;
use Net::DHCP::Constants qw(:DEFAULT :dhcp_hashes :dhcp_other %DHO_FORMATS);
use PeopleAPI::Database::Script;

$|=1;

my $script = PeopleAPI::Database::Script->new;
my $schema = $script->schema->clone;
my $machines = $schema->resultset('Machines');

sub execute {
  my ($self, $opt, $args) = @_;

  POE::Session->create(
    inline_states => {
      _start => \&_start,
      dhcp_monitor_sockbinderr 
        => sub {warn "Couldn't bind to port: Ensure you are running as root."},
      dhcp_monitor_packet => \&dhcp_monitor_packet,
    },
  );
  $poe_kernel->run();
}

sub _start {
  my ($kernel,$heap) = @_[KERNEL,HEAP];
  $heap->{monitor} = 
    POE::Component::DHCP::Monitor->spawn( alias => 'monitor' );
  say "Listening.";
  return;
}

sub dhcp_monitor_packet {
  my ($kernel,$heap,$packet) = @_[KERNEL,HEAP,ARG0];
  my $op = $REV_BOOTP_CODES{ $packet->op() };
  my $mac = substr( $packet->chaddr(), 0, 2 * $packet->hlen() );
  
  #say $packet->toString();
  
  if($op eq 'BOOTREPLY') {
    if(my $machine = $machines->find($mac)) {
      $machine->update({ ip => $packet->yiaddr() });
    }
  } elsif ($op eq 'BOOTREQUEST') {

    my $upd = {
      mac_address => $mac,
    };

    foreach my $key (@{$packet->{options_order}}) {
      given ($REV_DHO_CODES{$key}) {
        $upd->{host_name} = $packet->getOptionValue($key) when 'DHO_HOST_NAME';
        $upd->{host_class} = $packet->getOptionValue($key) when 'DHO_VENDOR_CLASS_IDENTIFIER';
        $upd->{host_identifier} = $packet->getOptionValue($key) when 'DHO_DHCP_CLIENT_IDENTIFIER';
      }
    }

    $machines->update_or_create($upd);

  }
  return;
}

1;