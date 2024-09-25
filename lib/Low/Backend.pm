package Low::Backend;
use Mojo::Base -base;
# use overload '""' => sub { shift->to_string }, '@{}' => sub { shift->to_array }, fallback => 1;

use Carp qw(croak);

use Mojo::Loader 'load_class';

has app => undef, weak => 1;
has dsn => sub { croak 'Attribute "dsn" is required' };

sub backend {
  my (undef, $app, $backend, $dsn) = (shift, shift, shift, shift);

  my $class = 'Low::Backend::' . $backend;
  my $e     = load_class $class;
  croak ref $e ? $e : qq{Backend "$class" missing} if $e;

  return $class->new($dsn, @_)->dsn($dsn)->app($app);
}

sub to_hash { return {$_[0]->to_string => $_[0]->dsn} }

sub to_string { ((split /::/, ref shift)[-1]) }

sub auto_retry_job {
  my ($self, $id, $retries, $attempts) = @_;
  return 1 if $attempts <= 1;
  my $delay = $self->minion->backoff->($retries);
  return $self->retry_job($id, $retries, {attempts => $attempts > 1 ? $attempts - 1 : 1, delay => $delay});
}

sub broadcast         { croak 'Method "broadcast" not implemented by subclass' }
sub dequeue           { croak 'Method "dequeue" not implemented by subclass' }
sub enqueue           { croak 'Method "enqueue" not implemented by subclass' }
sub fail_job          { croak 'Method "fail_job" not implemented by subclass' }
sub finish_job        { croak 'Method "finish_job" not implemented by subclass' }
sub history           { croak 'Method "history" not implemented by subclass' }
sub list_jobs         { croak 'Method "list_jobs" not implemented by subclass' }
sub list_locks        { croak 'Method "list_locks" not implemented by subclass' }
sub list_workers      { croak 'Method "list_workers" not implemented by subclass' }
sub lock              { croak 'Method "lock" not implemented by subclass' }
sub note              { croak 'Method "note" not implemented by subclass' }
sub receive           { croak 'Method "receive" not implemented by subclass' }
sub register_worker   { croak 'Method "register_worker" not implemented by subclass' }
sub remove_job        { croak 'Method "remove_job" not implemented by subclass' }
sub repair            { croak 'Method "repair" not implemented by subclass' }
sub reset             { croak 'Method "reset" not implemented by subclass' }
sub retry_job         { croak 'Method "retry_job" not implemented by subclass' }
sub stats             { croak 'Method "stats" not implemented by subclass' }
sub unlock            { croak 'Method "unlock" not implemented by subclass' }
sub unregister_worker { croak 'Method "unregister_worker" not implemented by subclass' }

1;