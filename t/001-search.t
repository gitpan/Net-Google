use strict;

use Test::More;

use constant TMPFILE    => "./blib/google-api.key";
use constant QUERY      => "related:http://perl.aaronland.net"; 
use constant MAXRESULTS => 50;

my $key = $ARGV[0];

if ($key) {
  &run_test();
}

elsif (open KEY , "<".TMPFILE) {
  $key = <KEY>;
  chomp $key;
  close KEY;

  &run_test();
}

else {
  plan tests => 1;
  ok($key,"Read Google API key");
}

sub run_test {
  plan tests => 5;

  ok($key,"Read Google API key");

  use_ok("Net::Google");
  my $google = Net::Google->new(key=>$key,debug=>0);
  
  isa_ok($google,"Net::Google");
  
  my $search = $google->search();
  isa_ok($search,"Net::Google::Search");
  
  $search->query(QUERY);
  $search->max_results(MAXRESULTS);
  
  my $results = $search->results();
  is(ref($results),"ARRAY","Got results for ".QUERY);
  
  print "Google returned ".scalar(@$results)." results:\n";
  map { print $_->URL()."\n"; } @{$results};
}

# $Id: 001-search.t,v 1.5 2003/03/07 04:26:28 asc Exp $

