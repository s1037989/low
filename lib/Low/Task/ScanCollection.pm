package Low::Task::ScanCollection;
use Mojo::Base 'Low::Task', -signatures;

use Low::Collection;

sub run ($self, $name) {
  $self->init($name);
    or return $self->fail('Cannot scan collection');

  my $collection = Low::Collection->new(name => $name)
    or return $self->fail('Invalid collection');

  $self->log->warn('Concurrent scan limit reached, delaying')
    and return $self->retry({delay => 60})
    unless my $guard = $self->minion->guard('scan_collection', 3600, {limit => 5});

  $collection->on(finished => sub ($collection, $finished) {
    $self->note(progress => 100, finished => $finished);
    $self->finish(sprintf 'Collection ready, processed %d/%d files', $finished, $collection->item_count);
  });
  $collection->on(progress => sub ($collection, $progress, $finished) {
    $self->note(progress => $progress, finished => $finished);
  });
  $collection->on(unfinished => sub ($collection, $unfinished) {
    $self->fail(sprintf 'Collection NOT ready, processed %d/%d files', $unfinished, $collection->item_count);
  });

  $self->log->info('Scanning collection');
  $collection->scan unless $self->app->mode eq 'dryrun';
}

1;