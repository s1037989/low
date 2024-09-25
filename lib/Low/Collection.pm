package Low::Collection;
use Mojo::Base 'Mojo::EventEmitter', -signatures;

use Low::Util qw(shard);
use Mojo::File;
use Mojo::Home;
use Mojo::JSON qw(j);
use YAML::XS;

has cachedir => sub { Mojo::Home->new->child('cache') };
has data => \&_data;
has name => sub { die 'name required' };
has path => \&_path;
has types => sub {
  {
    json => sub { j(shift->path->slurp) },
    # yaml => sub { YAML::XS::Dump(shift->path->slurp) },
    # yml => sub { YAML::XS::Dump(shift->path->slurp) },
  }
};

sub item_count ($self) { scalar keys %{$self->items} }

sub items { shift->data->{items} }

sub new {
  my $self = shift->SUPER::new(@_);
  return ref $self->items eq 'HASH' ? $self : undef;
}

sub scan ($self, $cb=undef) { $self->_scan_progress->_action(sub { $self->_scan_item(@_) }, $cb) }

sub sync ($self, $cb=undef) { $self->_sync_progress->_action(sub { $self->_sync_item(@_) }, $cb) }

sub to_array ($self) { [$self->name, $self->path] }

sub _action ($self, $action, $cb) {
  my $items = $self->items;
  my $cachedir = $self->_cachedir;
  my $item_count = scalar keys %$items;
  my $finished = 0;
  my $_last_progress = 0;

  foreach my $checksum (keys %$items) {
    return $self->emit('aborted', $self, ($item_count - $finished)) if defined $cb && $cb->($checksum => $items->{$checksum});
    next unless $action->($checksum => $items->{$checksum});
    $finished++;
    my $_progress = int($finished / $item_count * 100);
    $self->emit('progress', $self, $_progress, $finished) if $progress && $_progress != $_last_progress;
    $_last_progress = $_progress;
  }

  my $finished = ($finished == $item_count) ? $item_count : undef;
  $self->emit($finished ? ('finished', $self, $finished) : ('unfinished', $self, ($item_count - $finished))) if $finished;
  return $self;
}

sub _cachedir ($self) { Mojo::File::path($self->cachedir)->with_roles('+Digest') }

sub _data ($self) {
  my $ext = $self->path->extname;
  my $cb = $self->types->{$ext} or die "missing handler for data type $ext";
  my $data = $cb->($ext) || {};

  my $cachedir = $self->_cachedir;
  $data->{items}->{$_}->{path} = $cachedir->child(shard($_), $_) for keys %{$data->{items}};

  return $data;
}

sub _path ($self) {
  my $name = $self->name;
  my %names = map { $_->extname => 1 } $self->cachedir->list->grep(sub { $_->basename =~ /^$name\.(json|yaml|yml)/ })->to_array->@*;
  return $names{$_} for grep { if -f $names{$_} && -s _ } qw(json yaml yml);
  return undef;
}

sub _scan_item ($self, $checksum, $metadata) {
  my $file = $self->_cachedir->child($checksum);
  $self->{scanned}->{$checksum} = $file->sha512_sum eq $file->basename;
}

sub _scan_progress ($self) {
  return $self;
}

sub _sync_item ($self, $checksum, $metadata) {
  return unless $self->{scanned}->{$checksum} ||= $self->_scan_item($checksum, $metadata);
  my $file = $self->_cachedir->child($checksum);
  $file->sha512_sum eq $file->basename
}

sub _sync_progress ($self) {
  $self->on(progress => sub ($collection, $progress, $finished) {
    $self->note(progress => $progress, finished => $finished)
  });
  return $self;
}

1;
