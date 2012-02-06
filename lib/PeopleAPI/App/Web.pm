package PeopleAPI::App::Web;

use v5.14.0;
use Web::Simple;
use JSON::XS;
use Plack::Builder;
use PeopleAPI::Database::Script;
with('PeopleAPI::Role::Request');

# ABSTRACT: API to list people in the skiff

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
  sub (PUT + /ident) {
    my $data = decode_json $self->req->content;
    #get the local IP of the request
    #machine should've already broadcast for IP so we should have current
    #mac address
    if(my $client = $machines->search({ ip => $self->req->address }, {
        order_by => {-desc => ['last_seen'] }
      })->first) {
      $client->update({email => $data->{'hash'}});
      return [ 200, [ 'Content-type', 'text/plain' ], [ 'Linked' ] ];
    }
    return [ 404, [ 'Content-type', 'text/plain' ], [ "Couldn't find IP locally" ] ];
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

around 'to_psgi_app', sub {
  my ($orig,$self) = (shift, shift);
  my $app = $self->$orig(@_);
  builder {
    enable "JSONP", callback_key => 'callback';
    enable 'CrossOrigin', origins => 'http://skiffprofile.herokuapp.com';
    $app;
  };
};

__PACKAGE__->run_if_script;
