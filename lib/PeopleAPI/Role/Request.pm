package PeopleAPI::Role::Request;

use Moo::Role;
use Plack::Request;

has request => ( is => 'rw' );

sub req { return shift->request(@_) }

sub _build_request_obj_from {
  my ( $self, $env ) = @_;
  $self->request(Plack::Request->new($env));
  return $self->request;
}

before 'dispatch_request' => sub {
  my ($self,$env) = @_;
  $self->_build_request_obj_from($env);
};

1;
