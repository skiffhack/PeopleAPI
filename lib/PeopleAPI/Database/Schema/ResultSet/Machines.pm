package PeopleAPI::Database::Schema::ResultSet::Machines;

use base qw/DBIx::Class::ResultSet/;

my $considered_new = DateTime::Duration->new( hours => 1 );

sub active {
  my $self = shift;
  #sqlite doesn't use proper datetime
  my $dtf = $self->result_source->schema->storage->datetime_parser;
  $self->search_rs({
    'last_seen' => 
      { '>=' => $dtf->format_datetime(
          DateTime->now->subtract_duration($considered_new))  }
  })
}

1;