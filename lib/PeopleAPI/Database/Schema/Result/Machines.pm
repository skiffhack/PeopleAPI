package PeopleAPI::Database::Schema::Result::Machines;

use PeopleAPI::Database::Candy -components => [qw/ EncodedColumn UUIDColumns 
  InflateColumn::DateTime TimeStamp Helper::Row::ToJSON/];
use Class::Method::Modifiers;
use Net::Ping;

column 'mac_address' => {
  data_type   => 'varchar',
  size        => 17
};

column 'email' => {
  data_type   => 'varchar',
  size        => 100,
  is_nullable => 1,
  is_serializable => 1,
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
};

column 'host_identifier' => {
  data_type => 'varchar',
  size      => 50,
  is_nullable => 1,
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
  always_update => 1,
  is_serializable => 0,
};

sub ping {
  my $self = shift;
  if(my $ip = $self->ip) {
    my $p = Net::Ping->new('tcp');
    $self->update({}) if $p->ping($ip,0.2);
    $p->close;
  }
}

around ip => sub {
  my ($orig, $self) = (shift, shift);
 
  if (@_) {
    my $ip = $_[0];
    my $p = Net::Ping->new('syn');
    $self->is_firewalled($p->ping($ip,0.4) ? 0 : 1);
    $p->close;
  }
 
  $self->$orig(@_);
};

primary_key 'mac_address';

1;
