package Low::Controller::Collection;
use Mojo::Base 'Mojolicious::Controller', -signatures;

use Low::Collection;
use Low::Util qw(duration task_options);

sub post ($self) {
  my $collection = Low::Collection->new(path => $self->param('path'));
  my $name = $collection->name;
  my $path = $collection->path;
  my $minion = $self->app->minion;

  unless ($collection->is_valid) {
    $minion->jobs({tasks => ['scan_collection']})->each(sub {
      $minion->job($info->{id})->finish(sprintf '[%s] Archive collection', $name) if $info->{args}[0] eq $name;
    });
    $self->render(id => $id, name => $name, path => $path, archive => 1);
    return;
  }

  my $collections = $self->app->collections;
  my $id = $collections->not_ready($name) || $minion->enqueue(scan_collection => [$name, $path] => $self->_task_options);
  $self->render(id => $id, name => $name, path => $path);
}

sub _task_options ($self) {
  my $config = $self->app->config->{tasks}{collection};
  my $task_options = task_options($config);
  $task_options->{delay} = duration($config->{delay});
  $task_options->{expire} = duration($config->{expire});
  return $task_options;
}

1;
