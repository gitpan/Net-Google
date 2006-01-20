use strict;
use Test::More;

use constant TMPFILE => "./blib/google-api.key";

use constant WRONG   => "neu yirk citee";
use constant CORRECT => "new york city";

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
  
  my $spelling = $google->spelling();
  isa_ok($spelling,"Net::Google::Spelling");
  
  $spelling->phrase(WRONG);
  is($spelling->suggest(),CORRECT,"The correct spelling of '".WRONG."' is '".CORRECT."'");
}

# $Id: 002-spelling.t,v 1.1.1.1 2006/01/12 03:37:31 was Exp $
