package Low::Command::sync_collections;
use Mojo::Base 'Mojolicious::Command', -signatures;

use Low::Collection;
use Low::Util qw(task_options);

has description => 'Sync collections to media';
has usage       => sub { shift->extract_usage };

# This command should be run automatically when registered media is connected
# to the system. It will sync all collections to the media.
sub run ($self, $media) {
  my $self = shift;

  die $self->usage unless $media;

  my $log = $self->app->log->context('[sync_collection]', "[$media/-]");

  # If the media isn't registered but is connected, it will be ignored.
  my $owner = $self->app->media->owner(collections => $media);
  unless ($owner) {
    $log->warn('Media has no owner or cannot be used for transfer');
    return;
  }

  $log = $self->app->log->context('[sync_collection]', "[$media/$owner]");

  my $minion = $self->app->minion;

  # Sync all finished collections to registered media
  $minion->jobs({states => ['finished'], tasks => ['sync_collection']})->each(sub {
    my $name = $_->{args}[0];
    $log->add_context("[$name]")->info('Syncing collection');
    $self->app->enqueue(sync_collection => [$name, $media] => 'collection');
  });
}

1;

=encoding utf8

=head1 NAME

Low::Command::sync_collection - sync_collection command

=head1 SYNOPSIS

  Usage: APPLICATION sync_collection [OPTIONS]

    mojo sync_collection media

  Options:
    -h, --help   Show this summary of available options

=head1 DESCRIPTION

L<Low::Command::sync_collection> shows sync_collection information for available core and optional modules.

This is a core command, that means it is always enabled and its code a good example for learning to build new commands,
you're welcome to fork it.

See L<Mojolicious::Commands/"COMMANDS"> for a list of commands that are available by default.

=head1 ATTRIBUTES

L<Low::Command::sync_collection> inherits all attributes from L<Mojolicious::Command> and implements the following new
ones.

=head2 description

  my $description = $v->description;
  $v              = $v->description('Foo');

Short description of this command, used for the command list.

=head2 usage

  my $usage = $v->usage;
  $v        = $v->usage('Foo');

Usage information for this command, used for the help screen.

=head1 METHODS

L<Low::Command::sync_collection> inherits all methods from L<Mojolicious::Command> and implements the following new
ones.

=head2 run

  $v->run(@ARGV);

Run this command.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<https://mojolicious.org>.

=cut