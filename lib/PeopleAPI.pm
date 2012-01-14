package PeopleAPI;

use v5.14.0;
use Web::Simple;
use Net::Ping;
use JSON::XS;
use Plack::Builder;

my $cache = {};

sub dispatch_request {
  my $self = shift;
  sub (GET + /recent) {
    $self->get_hosts if(!$cache->{ts} || $cache->{ts} - time > 1000);
    [ 200, [ 'Content-type', 'application/json' ], [ encode_json $cache ]];
  }
}

sub get_hosts {
  my @alive;
  for my $cd (2..254) {
    my $p = Net::Ping->new('syn');
    my $ip = "192.168.11.$cd";
    push @alive,$ip if $p->ping($ip,0.4);
    $p->close;
  }

  my $arp = `arp -a`;
  $cache->{hosts} = [];
  foreach (@alive) {
    if($arp =~ /^\? \($_\) at ([0-9a-g:]*) /m) { push $cache->{hosts}, $1; }
  }
  $cache->{ts} = time;
}

around 'to_psgi_app', sub {
  my ($orig,$self) = (shift, shift);
  my $app = $self->$orig(@_);
  builder {
    enable "JSONP", callback_key => 'callback';
    $app;
  };
};

PeopleAPI->run_if_script;