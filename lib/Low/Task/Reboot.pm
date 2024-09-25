package Low::Task::Reboot;
use Mojo::Base 'Low::Task', -signatures;

sub run ($self) {
  $self->finish('Rebooting');
  qx(/sbin/reboot);
}

1;