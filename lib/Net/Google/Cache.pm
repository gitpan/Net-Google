{

=head1 NAME

Net::Google::Cache - simple OOP-ish interface to the Google SOAP API for cached documents

=head1 SYNOPSIS

 use Net::Google::Cache;
 my $cache = Net::Google::Cache($service,\%args);

 $cache->url("http://aaronland.net);
 print $cache->get();

=head1 DESCRIPTION

Provides a simple OOP-ish interface to the Google SOAP API for cached documents.

This package is used by I<Net::Google>.

=cut

package Net::Google::Cache;
use strict;

use Carp;
use Exporter;

$Net::Google::Cache::VERSION   = '0.13';
@Net::Google::Cache::ISA       = qw (Exporter);
@Net::Google::Cache::EXPORT    = qw ();
@Net::Google::Cache::EXPORT_OK = qw ();

=head1 Class Methods

=head2 $pkg = Net::Google::Cache->new($service,\%args)

Where I<$service> is a valid I<GoogleSearchService> object.

Valid arguments are :

=over 4

=item *

B<key>

String. Google API key. If none is provided then the key passed to the parent I<Net::Google> object will be used.

=item *

B<url>

String.

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
  my $self    = shift;
  my $service = shift;
  my $args    = shift;

  if (ref($service) ne "GoogleSearchService") {
    carp "Unknown service";
    return 0;
  }

  $self->{'_service'}  = $service;

  if (! $args->{'key'}) {
    carp "You must define a key";
    return 0;
  }

  $self->key($args->{'key'});

  if ($args->{'url'}) {
    $self->url($args->{'url'});
  }
  
  return 1;
}

=head2 $pkg->key($key)

Returns a string. Returns undef if there was an error.

=cut

sub key {
  my $self = shift;
  my $key  = shift;

  if (defined($key)) {
    $self->{'_key'} = $key;
  }

  return $self->{'_key'};
}

=head2 $pkg->url($url)

Set the cached URL to fetch from the Google servers. 

Returns a string. Returns an undef if there was an error.

=cut

sub url {
  my $self = shift;
  my $url  = shift;

  if (defined($url)) {
    $self->{'_url'} = $url;
  }

  return $self->{'_url'};
}

=head2 $pkg->get()

Fetch the requested URL from the Google servers.

Returns a string. Returns undef if there was an error.

=cut

sub get {
  my $self = shift;
  return $self->{'_service'}->doGetCachedPage(
					      $self->key(),
					      $self->url(),
					     );
}

=head1 VERSION

0.13

=head1 DATE

November 01, 2002

=head1 AUTHOR

Aaron Straup Cope

=head1 TO DO

=over 4

=item *

Add hooks to I<get> method to strip out Google headers and footers from cached pages.

=back

=head1 SEE ALSO

L<Net::Google>

=head1 LICENSE

Copyright (c) 2002, Aaron Straup Cope. All Rights Reserved.

This is free software, you may use it and distribute it under the same terms as Perl itself.

=cut

return 1;

}
