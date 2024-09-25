package Low::Util;
use Mojo::Base -strict;

use DateTime;
use DateTime::Duration;
use Digest::SHA qw(sha512_base64);
use Mojo::BaseUtil qw(monkey_patch);

our @EXPORT_OK = (
  qw(duration sha512_sum shard task_options),
);

monkey_patch(__PACKAGE__, 'sha1_sum', \&sha512_base64);

sub duration {
  my $dt = DateTime->now;
  my $duration = DateTime::Duration->new(@_);
  my $future_dt = $dt + $duration;
  return $future_dt->epoch - $dt->epoch;
}

sub shard ($checksum) { map { substr($checksum, 0, $_) } 1 .. 3 }

sub task_options ($task_options){
  $task_options->{expire} = duration(%{$task_options->{expire}}) if ref $task_options->{expire} eq 'HASH';
}

1;