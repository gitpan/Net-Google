use strict;

BEGIN { $| = 1; print "1..4\n"; }

use Net::Google;
use Cwd;

BEGIN{ push(@INC,&Cwd::getcwd()); }

my $key;
my $google;
my $search;

if (&t4(&t3(&t2(&t1)))) {
  print "Passed all tests\n";
}

sub t1 {

  print 
    "The Google API web service requires that you provide create a Google Account and obtain a license key\n",
      "This key is then passed with each request you make to the Google servers.\n",
	"If you do not already have a Google Account, you can sign up for one here:\n",
	  "http://www.google.com/apis/\n",
	    "\n";
  
  $key = &ask("Please enter your Google key");
  
  if ($key) {
    print "ok 1\n";
    return 1;
  } else {
    print "not ok 1\n";
    return 0;
  }
}

sub t2 {
  my $last = shift;

  if (! $last) {
    print "not ok 2\n";
    return 0;
  }

  my $debug = &ask_yesno("Would you like to enable debugging?");
  $google   = Net::Google->new(key=>$key,debug=>$debug);
  
  if (ref($google) eq "Net::Google") {
    print "ok 2\n";
    return 1;
  } else {
    print "not ok 2\n";
    return 0;
  }
}

sub t3 {
  my $last = shift;

  if (! $last) {
    print "not ok 3\n";
    return 0;
  }

  eval { $search = $google->search() };
  
  if (ref($search) eq "Net::Google::Search") {
    print "ok 3\n";
    return 1;
  } else {
    print $@;
    print "not ok 3\n";
    return 0;
  }
}

sub t4 {
  my $last = shift;

  if (! $last) {
    print "not ok 4\n";
    return 0;
  }

  my $query = &ask("Please enter a query string");
  $search->query($query);

  my $results = $search->results();
  
  if (! $results) {
    print "not ok 4\n";
    return 0;
  }

  print "Google returned the following results:\n";
  map { print $_->URL()."\n"; } @{$results};
  
  print "ok 4\n";
  return 1;
}

sub ask_yesno {
  my $answer = &ask(@_);
  return ($answer =~ /^y(es)*$/i) ? 1 : 0;
}

sub ask {
  my $question = shift;
  print "$question ";
  my $answer = <STDIN>;
  chomp $answer;
  return $answer;
}
