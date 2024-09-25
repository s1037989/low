package Low::Command;
use Mojo::Base -base, -signatures;

use Mojo::Home;

has 'cachedir' => sub { Mojo::Home->new->child('cache') };

sub active ($self) {
  $self->cachedir;
}

1;