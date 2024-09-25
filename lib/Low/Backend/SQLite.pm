package Low::Backend::SQLite;
use Mojo::Base 'Low::Backend';

use Mojo::File qw(curfile);
use Mojo::SQLite;

has 'sqlite';

sub new {
  my $self = shift->SUPER::new(sqlite => Mojo::SQLite->new(@_));

  my $schema = curfile->dirname->child('resources', 'migrations', 'sqlite.sql');
  $self->sqlite->auto_migrate(1)->migrations->name('low')->from_file($schema) if -e $schema;

  return $self;
}

1;