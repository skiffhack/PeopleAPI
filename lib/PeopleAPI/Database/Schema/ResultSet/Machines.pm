package PeopleAPI::Database::Schema::ResultSet::Machines;

use base qw/DBIx::Class::ResultSet/;

my $considered_new = DateTime::Duration->new( minutes => 5 );

sub active {
  my $self = shift;
  #sqlite doesn't stringify datetime correctly, DBIC fault
  my $dtf = $self->result_source->schema->storage->datetime_parser;
  $self->search_rs({
    'last_seen' => 
      { '>=' => $dtf->format_datetime(
          DateTime->now->subtract_duration($considered_new))  }
  })
}

{
  my $updated = time;
  sub refresh {
    my $self = shift;
    if(time - $updated > 300) {
      foreach my $machine ($self->today->search({ is_firewalled => 0 })->all) {
        $machine->ping();
      }
      $updated = time;
    }
    return $self;
  }
  
}

sub with_identifiers {
  return shift->search_rs({'email' =>  { '!=', undef }});
}

sub today {
  my $self = shift;
  my $dtf = $self->result_source->schema->storage->datetime_parser;
  $self->search_rs({
    'last_seen' => 
      { '>=' => $dtf->format_datetime( DateTime->now->set_hour(0)->set_minute(0))  }
  })
}
1;