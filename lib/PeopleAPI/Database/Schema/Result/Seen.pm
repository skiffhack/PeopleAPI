package PeopleAPI::Database::Schema::Result::Seen;

use PeopleAPI::Database::Candy
  -components => [qw/ EncodedColumn UUIDColumns 
                      InflateColumn::DateTime TimeStamp/];

column 'email' => {
  data_type => 'varchar',
  size => 100,
  is_nullable => 1,
};

column 'mac' => {
  data_type => 'varchar',
  size      => 100
};

column 'ip' => {
  data_type => 'varchar',
  size      => 100
};

column 'last_seen' => {
  'data_type'     => 'datetime',
  'set_on_create' => 0,
  'set_on_update' => 1,
};
