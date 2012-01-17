package PeopleAPI::Database::Schema::Result;

use parent 'DBIx::Class::Core';

__PACKAGE__->load_components(qw/Helper::Row::RelationshipDWIM/);
sub default_result_namespace { 'PeopleAPI::Database::Schema::Result' }
1;