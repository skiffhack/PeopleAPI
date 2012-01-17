package PeopleAPI::Database::Candy;

use base 'DBIx::Class::Candy';

sub base { $_[1] || 'PeopleAPI::Database::Schema::Result' }
sub perl_version { 12 }
sub autotable { 1 }

1;