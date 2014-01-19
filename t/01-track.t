#!perl -T
use strict;
use warnings;
use Test::More tests => 4;
use Test::GetVolatileData;
use Test::Deep;
use WWW::Purolator::TrackingInfo;

my $t = WWW::Purolator::TrackingInfo->new;

isa_ok($t, 'WWW::Purolator::TrackingInfo');
can_ok($t, qw/new error track/);

my $key = get_data('http://zoffix.com/CPAN/WWW-Purolator-TrackingInfo.txt')
    || '320698578202';

my $info = $t->track($key);

if ( $info ) {
    cmp_deeply(
      $info,
        {
            'pin' => re('\w+'),
            'status' => re('^(in transit|package picked up|shipping label created|attention|delivered)$'),
            'history' => array_each(
                 {
                   'comment' => re('.+'),
                   'location' => re('.+'),
                   'scan_time' => re('\A\d{1,2}:\d{2}:\d{2}\z'),
                   'scan_date' => re('\A\d{4}-\d{2}-\d{2}'),
                 }
            ),
        },
      'Tracking info looks fine',
    );
}
else {
    diag 'Got error tracking: ' . $t->error ? $t->error : '[undefined]';
    ok(length $t->error, 'Error got something');
    skip q|Didn't get proper tracking info to do more tests.|, 0;
}

$info = $t->track('INVALID_KEY');
ok( length $t->error, 'Error got something when using invalid key' );
