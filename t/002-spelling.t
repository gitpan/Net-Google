use strict;
use Test::More;


use constant TMPFILE => "./blib/google-api.key";
use constant WRONG   => "muntreal qweebec";
use constant CORRECT => "montreal quebec";

my $key = $ARGV[0];

if ((! $key) && (open KEY , "<".TMPFILE)) {
  plan tests => 5;

  $key = <KEY>;
  chomp $key;
  close KEY;

  ok($key,"Read Google API key");
  use_ok("Net::Google");

  my $google = Net::Google->new(key=>$key,debug=>0);
  isa_ok($google,"Net::Google");
  
  my $spelling = $google->spelling();
  isa_ok($spelling,"Net::Google::Spelling");
  
  $spelling->phrase(WRONG);
  is($spelling->suggest(),CORRECT,"The correct spelling of '".WRONG."' is '".CORRECT."'");

  exit;
}

plan tests => 1;
ok($key,"Read Google API key");
