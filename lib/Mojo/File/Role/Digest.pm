package Mojo::File::Role::Digest;
use Mojo::Base -strict, -role, -signatures;

our $VERSION = '0.04';

requires 'open';

use Carp 'croak';
use Digest::MD5;
use Digest::SHA;

sub md5_sum ($self) {
  return $self->_calcdigest(Digest::MD5->new);
}

sub sha1_sum ($self) {
  return $self->_calcdigest(Digest::SHA->new(1));
}

sub sha512_sum ($self) {
  return $self->_calcdigest(Digest::SHA->new(512));
}

sub _calcdigest ($self, $module, $fn = 'hexdigest') {
  return -f $self ? $module->addfile($self->open('<'))->$fn : '';
}

1;