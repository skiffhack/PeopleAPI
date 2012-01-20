package PeopleAPI::App::Web;

use v5.14.0;
use Web::Simple;
use Net::Ping;
use JSON::XS;
use Plack::Builder;
use PeopleAPI::Database::Script;

my $cache = {};

my $script = PeopleAPI::Database::Script->new;
my $schema = $script->schema->clone;
my $machines = $schema->resultset('Machines');

sub dispatch_request {
  my $self = shift;
  sub (GET + /recent) {
    my @all = $machines->refresh->active->all;
    $self->json_response({json => {
      total => scalar @all, 
      recent => [ map {$_->TO_JSON}  @all ]
    }})
  },
  sub (GET + /all) {
    my @all = $machines->refresh->all;
    $self->json_response({json => {
      total => scalar @all, 
      recent => [ map {$_->TO_JSON}  @all ]
    }})
    
  },
  sub (GET + /count) {
    $self->json_response({json => { total => $machines->refresh->active->count } });
  }
  
}

sub json_response {
  my ( $self, $args ) = @_;
  my ( $header, $json, $head, $status ) = @$args{qw/header json head status/};
  return [ $status || 200, [
      $header ? ( %$header ) : (),
      'Content-type' => 'application/json; charset=utf-8',
  ], [ encode_json $json ] ];
}

sub get_hosts_arp {
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

__PACKAGE__->run_if_script;