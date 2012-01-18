package PeopleAPI::Database::Schema::Result::Machines;

use PeopleAPI::Database::Candy -components => 
  [qw/ EncodedColumn UUIDColumns InflateColumn::DateTime TimeStamp Helper::Row::ToJSON/];

column 'mac_address' => {
  data_type   => 'varchar',
  size        => 17
};

column 'email' => {
  data_type   => 'varchar',
  size        => 100,
  is_nullable => 1,
  is_serializable => 0,
};

column 'ip' => {
  data_type => 'varchar',
  size      => 15,
  is_nullable => 1,
};

column 'host_name' => {
  data_type => 'varchar',
  size      => 50,
  is_nullable => 1,
};

column 'is_firewalled' => {
  data_type     => 'bool',
  default_value => 0,
  is_serializable => 0,
};

column 'host_class' => {
  data_type => 'varchar',
  size      => 50,
  is_nullable => 1,
};

column 'last_seen' => {
  data_type     => 'datetime',
  set_on_create => 1,
  set_on_update => 1,
  is_serializable => 0,
};

primary_key 'mac_address';

1;