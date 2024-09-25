package Low::Task::Shutdown;
use Mojo::Base 'Low::Task', -signatures;

sub run ($self) {
  $self->finish('Shutting down');
  qx(/sbin/shutdown -h now);
}

1;