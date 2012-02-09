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

my $opts = [
  {icmp => undef},
  {tcp => 548},
  {tcp => 5000},
  {tcp => 8080},
];

sub ping {
  my $self = shift;
  if(my $ip = $self->ip) {
    foreach my $opt ($opts) {
      foreach my $key (keys %$opt) {
        my ($proto, $port) = ($key ,$opt->{$key});
        my $p = Net::Ping->new($proto,0.1);
        $p->port_number($port) if $port;
        $self->update({}) if $p->ping($ip);
        $p->close;
      }
      
    }
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
