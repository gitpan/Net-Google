{

=head1 NAME

Net::Google - simple OOP-ish interface to the Google SOAP API

=head1 SYNOPSIS

 use Net::Google;
 use constant LOCAL_GOOGLE_KEY => "********************************";

 my $google = Net::Google->new(key=>LOCAL_GOOGLE_KEY);
 my $search = $google->search();

 # Search interface

 $search->query(qw(aaron straup cope));
 $search->lr(qw(en fr));
 $search->ie("utf8");
 $search->oe("utf8");
 $search->starts_at(5);
 $search->max_results(15);

 map { print $_->title()."\n"; } @{$search->results()};

 # or...

 foreach my $r (@{$search->response()}) {
   print "Search time :".$r->searchTime()."\n";

   # returns an array ref of Result objects
   # the same as the $search->results() method
   map { print $_->URL()."\n"; } @{$r->resultElements()};
 }

 # Spelling interface

 print $google->spelling(phrase=>"muntreal qwebec")->suggest(),"\n";

 # Cache interface

 my $cache = $google->cache(url=>"http://search.cpan.org/recent");
 print $cache->get();

=head1 DESCRIPTION

Provides a simple OOP-ish interface to the Google SOAP API

=cut

package Net::Google;
use strict;

use Carp;
use Exporter;

use Net::Google::Search;
use Net::Google::Spelling;
use Net::Google::Cache;
use Net::Google::Service;

$Net::Google::VERSION   = '0.52';
@Net::Google::ISA       = qw ( Exporter );
@Net::Google::EXPORT    = qw ();
@Net::Google::EXPORT_OK = qw ();

=head1 Google methods

=head2 $google = Net::Google->new(%args)

Valid arguments are :

=over 4

=item *

B<key>

I<String>. 

=item *

B<debug>

I<Boolean>

=back

=cut

sub new {
  my $pkg = shift;
  
  my $self = {};
  bless $self,$pkg;

  if (! $self->init(@_)) {
    return undef;
  }

  return $self;
}

sub init {
  my $self = shift;
  my $args = {@_};

  $self->{'_debug'} = $args->{'debug'};
  $self->{'_key'}   = $args->{'key'};
  return 1;
}

=head2 $google->search(%args)

Valid arguments are :

=over 4

=item *

B<key>

String. Google API key. If none is provided then the key passed to the parent I<Net::Google> object will be used.

=item *

B<starts_at>

Int. First result number to display. Default is 0.

=item *

B<max_results>

Int. Number of results to return. Default is 10.

=item *

B<lr>

String or array reference. Language restrictions.

=item *

B<ie>

String or array reference. Input encoding.

=item *

B<oe>

String or array reference. Output encoding.

=item *

B<safe>

Boolean.

=item *

B<filter>

Boolean.

=back

Returns a I<Net::Google::Search> object. Returns undef if there was an error.

=cut

sub search {
  my $self = shift;
  my $args = {@_};

  my $key   = (defined($args->{'key'}))   ? $args->{key}   : $self->{'_key'};
  my $debug = (defined($args->{'debug'})) ? $args->{debug} : $self->{'_debug'};

  $args->{debug} = $debug;
  $args->{key}   = $key;

  return Net::Google::Search->new(
 				  Net::Google::Service->search("search",{debug=>$debug}),
				  $args,
				 );
}

=head2 $pkg->spelling(%args)

=over 4

=item *

B<key>

String. Google API key. If none is provided then the key passed to the parent I<Net::Google> object will be used.

=item *

B<phrase>

String or array reference.

=item *

B<debug>

Int.If none is provided then the debug argument passed to the parent I<Net::Google> object will be used.

=back

Returns a I<Net::Google::Spelling> object. Returns undef if there was an error.

=cut

sub spelling {
  my $self = shift;
  my $args = {@_};

  my $key   = (defined($args->{'key'}))   ? $args->{key}   : $self->{'_key'};
  my $debug = (defined($args->{'debug'})) ? $args->{debug} : $self->{'_debug'};

  $args->{debug} = $debug;
  $args->{key}   = $key;

  return Net::Google::Spelling->new(
				    Net::Google::Service->spelling({debug=>$debug}),
				    $args,
				   );
}

=head2 $pkg->cache(%args)

Valid arguments are :

=over 4

=item *

B<key>

String. Google API key. If none is provided then the key passed to the parent I<Net::Google> object will be used.

=item *

B<url>

String.

=item *

B<debug>

Int.If none is provided then the debug argument passed to the parent I<Net::Google> object will be used.

=back

Returns a I<Net::Google::Cache> object. Returns undef if there was an error.

=cut

sub cache {
  my $self = shift;
  my $args = {@_};

  my $key   = (defined($args->{'key'}))   ? $args->{key}   : $self->{'_key'};
  my $debug = (defined($args->{'debug'})) ? $args->{debug} : $self->{'_debug'};

  $args->{debug} = $debug;
  $args->{key}   = $key;

  return Net::Google::Cache->new(
				 Net::Google::Service->cache({debug=>$debug}),
				 $args,
				);
}

=head1 VERSION

0.52

=head1 DATE

November 02, 2002

=head1 AUTHOR

Aaron Straup Cope

=head1 CONTRIBUTORS

Marc Hedlund <marc@precipice.org>

=head1 SEE ALSO

http://www.google.com/apis

L<Net::Google::Search>

L<Net::Google::Spelling>

L<Net::Google::Cache>

L<Net::Google::Response>

L<Net::Google::Service>

http://aaronland.info/weblog/archive/4231

=head1 TO DO

=over 4

=item * 

Tickle the tests so that they will pass on systems without 
Test::More - this is planned for 0.53

=item *

Add tests for filters - this is planned for either 0.53 or
0.54

=item *

Add some sort of functionality for managing multiple keys. 
Sort of like what is describe here :

http://aaronland.net/weblog/archive/4204

This will probably happen around the time Hell freezes over
so if you think you can do it faster, go nuts.

=back

=head1 BUGS

Please report all bugs via http://rt.cpan.org

=head1 LICENSE

Copyright (c) 2002, Aaron Straup Cope. All Rights Reserved.

This is free software, you may use it and distribute it under the same terms as Perl itself.

=cut

return 1;

}
