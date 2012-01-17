package PeopleAPI::App::CLI::Command::Deploy;
use PeopleAPI::App::CLI -command;
use Try::Tiny;
use PeopleAPI::Database::Script;

sub validate_args {
  my ($self, $opt, $args) = @_;
  $self->usage_error("no args expected") if @$args;
}

sub execute {
  my ($self, $opt, $args) = @_;

  my $script = PeopleAPI::Database::Script->new;
  my $schema = $script->schema->clone;

  $schema->deploy({ add_drop_table => 1 });
  $self->populate_data($schema);
}

sub populate_data {
  my ($self,$schema) = @_;
  
}

1;