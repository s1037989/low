package Low::Command::shutdown;
use Mojo::Base 'Mojolicious::Command';

has description => 'Shutdown system';
has usage       => sub { shift->extract_usage };

sub run {
  my $self = shift;
  $self->app->minion->enqueue(shutdown => [], {queue => 'root'});
}

1;

=encoding utf8

=head1 NAME

Low::Command::purge - purge command

=head1 SYNOPSIS

  Usage: APPLICATION purge [OPTIONS]

    mojo purge

  Options:
    -h, --help   Show this summary of available options

=head1 DESCRIPTION

L<Low::Command::purge> shows purge information for available core and optional modules.

This is a core command, that means it is always enabled and its code a good example for learning to build new commands,
you're welcome to fork it.

See L<Mojolicious::Commands/"COMMANDS"> for a list of commands that are available by default.

=head1 ATTRIBUTES

L<Low::Command::purge> inherits all attributes from L<Mojolicious::Command> and implements the following new
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

L<Low::Command::purge> inherits all methods from L<Mojolicious::Command> and implements the following new
ones.

=head2 run

  $v->run(@ARGV);

Run this command.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<https://mojolicious.org>.

=cut