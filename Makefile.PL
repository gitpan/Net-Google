use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
	      'NAME'	=> 'Net::Google',
	      ($[ >= 5.005) ?
	      (AUTHOR   => 'Aaron Straup Cope (cpan@aaronland.net)',
	       ABSTRACT => 'Simple OOP-ish interface to the Google API') : (),
	      'VERSION_FROM' => 'lib/Net/Google.pm',
	      'PREREQ_PM'    => {
				 SOAP::Lite    => 0, 
				 Carp          => 0,
				 # For tests
				 Cwd           => 0,
				},
	      dist	        => {COMPRESS => 'gzip', SUFFIX => 'tar.gz'},
);
