package PeopleAPI::Database::Schema::Result::Machines;

use PeopleAPI::Database::Candy -components => 
  [qw/ EncodedColumn UUIDColumns InflateColumn::DateTime TimeStamp/];

column 'mac_address' => {
  data_type   => 'varchar',
  size        => 100
};

column 'email' => {
  data_type   => 'varchar',
  size        => 100,
  is_nullable => 1,
};

column 'ip' => {
  data_type => 'varchar',
  size      => 100
};

column 'host_name' => {
  data_type => 'varchar',
  size      => 100
};

column 'is_firewalled' => {
  data_type     => 'bool',
  default_value => 0,
};

column 'host_class' => {
  data_type => 'varchar',
  size      => 100
};

column 'last_seen' => {
  data_type     => 'datetime',
  set_on_create => 0,
  set_on_update => 1,
};

primary_key 'mac_address';

1;