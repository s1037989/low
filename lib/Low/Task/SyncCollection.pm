package Low::Task::SyncCollection;
use Mojo::Base 'Low::Task', -signatures;

use Low::Collection;

sub run ($self, $name, $media) {
  my $owner = $self->app->media->get_owner($self->task => $media);

  $self->init($name, $media, $owner);
    or return $self->fail('Media can not be used to sync collections');

  my $collection = Low::Collection->new(name => $name)
    or return $self->fail('Invalid collection');
  
  $self->log->warn('Syncronization already in progress, delaying')
    and return $self->retry({delay => 60})
    unless my $guard = $self->minion->guard("sync_collection_$media", 86_400);

  my $item_count = $collection->item_count;
  $collection->on(aborted => sub ($collection, $unfinished) {
    $self->fail('Collection sync aborted');
  });
  $collection->on(finished => sub ($collection, $finished) {
    $self->note(progress => 100, finished => $finished);
    $self->finish(sprintf 'Collection sync finished, wrote %d/%d files', $finished, $item_count);
  });
  $collection->on(progress => sub ($collection, $progress, $finished) {
    $self->note(progress => $progress, finished => $finished);
  });
  $collection->on(unfinished => sub ($collection, $unfinished) {
    $self->fail('Collection sync NOT finished');
  });

  $self->log->info('Syncing to registered media');
  $collection->sync(sub ($checksum, $item) {
    return 1;
  }) unless $self->app->mode eq 'dryrun';
}

1;