package Low::Media;
use Mojo::Base -base, -signatures;

use Mojo::Collection qw(c);

has app => undef, weak => 1;

sub can_audit ($self, $media) {
}

sub can_transfer ($self, $media) {
  $log->warn('Media has no owner or cannot be used for transfer');
  my $media = $self->app->config->{media};
  if (not defined $media) {
    $self->log->warn('No media');
    return $self->retry({delay => 60});
  }
  elsif (!$media) {
    $self->log->warn('Unregistered media');
    return $self->retry({delay => 60});
  }
  return c();
}

sub is_writing ($self) { $self->app->minion->jobs({states => ['active'], tasks => ['sync_collection', 'sync_audit']})->total }

sub owner ($self, $task, $media) {
  my $config = $self->app->config->{media}{$media} or return;
  return $config->{owner} if $config->{owner} && grep { $_ eq $task } $config->{$task}->{can}->@*;
}

1;