package Low;
use Mojo::Base 'Mojolicious', -signatures;

use Carp qw(croak);

use Low::Backend;
use Low::Util qw(task_options);
use Mojo::BaseUtil qw(monkey_patch);

monkey_patch('Mojo::Log', 'add_context', sub ($self, @context) {
  $self->tap(sub { $_ = $_->context($_->{context}->@*, @context)})
});

# This method will run once at server start
sub startup ($self) {

  push @{$self->commands->namespaces}, 'Low::Command';

  # Load configuration from config file
  my $config = $self->plugin('NotYAMLConfig' => {
    default => {
      backend => [SQLite => 'sqlite:low.db'],
      media => {
        abc123 => 'adamssm',
      },
      tasks => {
        collection => {
          queue => 'collection',
          priority => 1,
          attempts => 25,
          expire => {month => 1},
        },
        root => {
          queue => 'root',
          priority => 100,
        },
      }
    }
  });

  my $backend = Low::Backend->backend($self->app, @{$config->{backend}});

  $self->plugin('Minion' => $backend->to_hash);
  $self->plugin('Minion::Admin');
  $self->plugin('Minion::AutoPerform');

  # $self->helper(collections => sub ($app) { state $collections = Low::Collections->new(app => $app) });
  $self->helper(media => sub ($app) { state $media = Low::Media->new(app => $app) });
  $self->helper(enqueue => sub ($c, $task, $args=[], $options=undef) {
    $c->app->log->add_context("[$task]")->info('Enqueueing');
    $c->app->minion->enqueue($task => $args => ref $options eq 'HASH' ? $options : task_options($config->{tasks}{$options || $task})) unless $c->app->mode eq 'dryrun';
  });

  # Configure the application
  $self->secrets($config->{secrets});

  # Router
  my $r = $self->routes;
  # authentication for api end points
  my $api = $r->under('/' => sub ($c) {
    return 1 if $c->config->{tokens}->{$c->req->headers->header('X-Low-Token')};
    $c->reply->exception('Unauthorized');
    return undef;
  });
  # authentication for web end points
  my $web = $r->under('/' => sub ($c) {
    return 1;
  });

  # Normal route to controller
  $web->post('/cache')->to('Example#welcome');
  $api->post('/collection/:name')->to('Collection#post');
  $api->any('/:subaction')->to('Action#handler');
}

1;
