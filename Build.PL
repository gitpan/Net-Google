# $Id: Build.PL,v 1.2 2006/01/12 07:00:50 was Exp $

use strict;
use Module::Build;

my $class = Module::Build->subclass( code => <<'EOC' 
				     sub process_wsdl_files {
					 my $self = shift;
					 my $files = $self->_find_file_by_type('wsdl', 'lib');
					 while (my ($file, $dest) = each %$files) {
					     $self->copy_if_modified(from => $file, to => File::Spec->catfile($self->blib, $dest) );
					 }
				     }
EOC
				     );

my $build = $class->new(module_name => 'Net::Google',
			       # dist_author
			       # dist_abstract
			       dist_version_from => 'lib/Net/Google.pm',
			       license           => 'perl',
			       requires => {
				   'SOAP::Lite'     => '>= 0.55',
				   'LWP::Protocol'  => '>= 1.42',
				   'Carp'           => '>= 0',
			       },
			       build_requires => {
				   'Test::Simple'  => '>= 0.47',
			       },
			       create_readme      => 1,
			       create_makefile_pl => 'passthrough');

#can't use add_build_element as it doesn't work for older versions of Module::Build
#$build->add_build_element('wsdl');
push @{$build->build_elements}, 'wsdl';
$build->create_build_script();
