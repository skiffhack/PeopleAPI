package PeopleAPI::App::CLI::Command::DHCPDMonitor;

use Moo;
use PeopleAPI::App::CLI -command;
use POE;
use POE::Component::DHCP::Monitor;
use Net::DHCP::Packet;
use Net::DHCP::Constants qw(:DEFAULT :dhcp_hashes :dhcp_other %DHO_FORMATS);
use Net::Ping;
use PeopleAPI::Database::Script;

$|=1;

my $script = PeopleAPI::Database::Script->new;
my $schema = $script->schema->clone;


sub execute {
  my ($self, $opt, $args) = @_;

  POE::Session->create(
    inline_states => {
      _start              => \&_start,
      dhcp_monitor_packet => \&dhcp_monitor_packet,
    },
  );
  $poe_kernel->run();
}

sub _start {
  my ($kernel,$heap) = @_[KERNEL,HEAP];
  $heap->{monitor} = 
  POE::Component::DHCP::Monitor->spawn(
    alias => 'monitor'
  );
  return;
}

sub dhcp_monitor_packet {
  my ($kernel,$heap,$packet) = @_[KERNEL,HEAP,ARG0];
  foreach my $key (@{$packet->{options_order}}) {
    if($REV_DHO_CODES{$key} eq 'DHO_HOST_NAME') {
      my $upd = {
        ip => $packet->ciaddr(),
        mac_address => substr( $packet->chaddr(), 0, 2 * $packet->hlen() ),
        host_name => $packet->getOptionValue($key),
        host_class => ""
      };
      
      #simple check for if machine is firewalled
      my $p = Net::Ping->new('syn');
      $upd->{is_firewalled} = $p->ping($upd->{ip},0.4) ? 1 : 0;
      $p->close;
      use Data::Dumper;warn Dumper($upd);
      $schema->resultset('Seen')->update_or_create($upd);
    }
  }
  return;
}

1;