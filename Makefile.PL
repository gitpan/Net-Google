use ExtUtils::MakeMaker;
WriteMakefile(
	      'NAME'	=> 'Net::Google',
	      ($[ >= 5.005) ?
	      (AUTHOR   => 'Aaron Straup Cope (cpan@aaronland.net)',
	       ABSTRACT => 'Simple OOP-ish interface to the Google API') : (),
	      'VERSION_FROM' => 'lib/Net/Google.pm',
	      'PREREQ_PM'    => {
				 SOAP::Lite          => '0',
				 LWP::Protocol::file => '0',
				 Carp                => '0',
				 Test::More          => '0',
				 Cwd                 => '0',
				},
	      dist	        => {COMPRESS => 'gzip', SUFFIX => 'tar.gz'},
);
