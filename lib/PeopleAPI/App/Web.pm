package PeopleAPI::App::Web;

use v5.14.0;
use Web::Simple;
use JSON::XS;
use Plack::Builder;
use PeopleAPI::Database::Script;
use DateTime;
with('PeopleAPI::Role::Request');

# ABSTRACT: API to list people in the skiff

my $cache = {};

my $script = PeopleAPI::Database::Script->new;
my $schema = $script->schema->clone;
my $machines = $schema->resultset('Machines');
my $considered_new = DateTime::Duration->new( minutes => 5 );

sub dispatch_request {
  my $self = shift;
  sub (GET + /recent) {
    my @all = $machines->refresh->active->all;
    $self->json_response({json => {
      total => scalar @all, 
      recent => [ 
        map { {
          hash => $_->email,
          last_seen => $_->last_seen.""
        } }  @all 
      ]
    }})
  },
  sub (PUT | POST + /ident) {
    my $data = decode_json $self->req->content;
    #get the local IP of the request
    #machine should've already broadcast for IP so we should have current
    #mac address
    if(my $client = $machines->refresh->search({ ip => $self->req->address }, {
        order_by => {-desc => ['last_seen'] }
      })->first) {
      $client->update({email => $data->{'hash'}});
      return [ 200, [ 'Content-type', 'text/plain' ], [ 'Linked' ] ];
    }
    return [ 404, [ 'Content-type', 'text/plain' ], [ "Couldn't find IP locally" ] ];
  },
  sub (GET + /status/* ) {
    my ($self, $hash ) = @_;
    if(my $client = $machines->search({ email => $hash })->first) {
      $self->json_response({json => { 
        known => JSON::XS::true,
        present => 
          $client->last_seen->clone->add_duration($considered_new) > DateTime->now() ?
          JSON::XS::true : JSON::XS::false,
        last_seen => $client->last_seen.""
      }});
    } else {
      $self->json_response({json => { 
        known => JSON::XS::false,
      }});
    }
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

__PACKAGE__->run_if_script;
