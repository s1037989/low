package Low::Collections;
use Mojo::Base -base;

use List::Compare;
use Mojo::Collection;

has app => undef, weak => 1;

sub not_ready ($self, $name=undef) { $self->_find($name, ['active', 'inactive'], ['scan_collection']) }

sub not_written ($self, $name=undef) { $self->_find($name, ['active', 'inactive'], ['write_collection']) }

sub ready ($self, $name=undef) { $self->_find($name, ['finished'], ['scan_collection']) }

sub ready_not_written ($self, $name=undef) {
  my $scan = $self->_find($name, ['finished'], ['scan_collection']);
  my $write = $self->_find($name, ['active', 'inactive'], ['write_collection']);
  my $lc = List::Compare->new($scan, $write);
  return $lc->get_Lonly;
}

sub written ($self, $name=undef) { $self->_find($name, ['finished'], ['write_collection']) }

sub _find ($self, $name, $states, $tasks) {
  my $minion = $self->app->minion;

  my $ids = Mojo::Collection->new;
  my $jobs = $minion->jobs({states => $states, tasks => $tasks});
  while (my $info = $jobs->next) {
    return c($info->{id}) if $info->{args}[0] eq $name;
    push @$ids, $info->{id};
  }
  return $ids->size ? $ids : $ids->new(undef);
}

1;
