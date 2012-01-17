package PeopleAPI::Database::Script;

use Moo;
use PeopleAPI::Database::Schema;
use Config::Any;

has 'dsn' => (is => 'rw', predicate => 'has_dsn');
has 'user' => (is => 'rw', default => sub {""}, predicate => 'has_user');
has 'password' => (is => 'rw', default => sub {""}, predicate => 'has_password');
has 'schema' => ( is => 'ro', lazy => 1, builder => '_build_schema' );
has 'dbname' => ( is => 'ro', lazy => 1, builder => '_build_dbname' );

sub _build_dbname {
  my $self = shift;
  return $self->dsn =~ /dbname=([^;]*)/ ? $1 : undef;
}

sub BUILD {
  my $self = shift; 
  my $backup_uid = `whoami`; chomp $backup_uid;
  my $username = $ENV{USER} || getpwuid($<);
  my $cfg = Config::Any->load_stems(
    { stems => [ "etc/conf/peopleapi_${username}" ], use_ext => '1' },
  );
  my %db_info = (
    (map { %{$_->{'Model::Database'}->{'connect_info'}} }
      map { values %$_ } @ $cfg)
  );
  foreach my $option (qw/dsn user password/) {
    my $predicate = "has_${option}";
    $self->$option($db_info{$option}) unless $self->$predicate;
  }
}

sub _build_schema {
  my $self = shift;
  my @conn_info = map { $self->$_ } qw(dsn user password);
  my $schema = PeopleAPI::Database::Schema->connect(@conn_info);
  return $schema;
}

1;