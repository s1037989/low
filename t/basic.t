use Mojo::Base -strict;

use Mojo::File qw(curfile);
use lib curfile->dirname->sibling('lib')->to_string;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('Low');
$t->get_ok('/')->status_is(200)->content_like(qr/Mojolicious/i);
$t->get_ok('/minion')->status_is(200)->content_like(qr/Minion - Dashboard/i);

done_testing();
