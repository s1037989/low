package Low::Controller::Action;
use Mojo::Base 'Mojolicious::Controller', -signatures;

use Low::Util qw(task_options);

sub handler ($self) {
  my $action = '_' . $self->req->method . '_' . $self->param('subaction');
  $self->can($action) ? $self->$action : $self->reply->exception('Invalid command');
}

sub _get_reboot ($self) {
  my $task_options = task_options($self->app->config->{tasks}{root});
  $self->app->minion->enqueue(reboot => [] => $task_options);
  $self->render(text => 'Rebooting');
}

sub _get_shutdown ($self) {
  my $task_options = task_options($self->app->config->{tasks}{root});
  $self->app->minion->enqueue(shutdown => [] => $task_options);
  $self->render(text => 'Shutting down');
}

1;
