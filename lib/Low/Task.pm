package Low::Task;
use Mojo::Base 'Minion::Job', -signatures;

has cachedir => sub { Mojo::Home->new->child('cache') };
has log => sub { shift->app->log };

sub init ($self, $name, $media=undef, $owner=undef) {
  my $log = $self->app->log->context('[' . $self->task . ']', '[' . $name . ']');
  $log = $log->add_context("[$media/".($owner||'-')."]") if $media;
  $self->log($log);

  $self->on(finished => sub ($job, $result) {
    $log->info(sprintf '[%s] [%s] %s', $job->id, $job->info->{state}, $result);
  });
  $self->on(failed => sub ($job, $err) {
    $log->error(sprintf '[%s] [%s] %s', $job->id, $job->info->{state}, $err);
  });

  return $media && !$owner ? undef : $self;
}

1;
