{

=head1 NAME

Net::Google::Spelling

=head1 SYNOPSIS

 use Net::Google::Spelling;
 my $spelling = Net::Google::Spelling($service,\%args);

 $spelling->phrase("muntreal qweebec");
 print $spelling->suggest()."\n";

=head1 DESCRIPTION

Provides a simple OOP-ish interface to the Google SOAP API for spelling suggestions.

This package is used by I<Net::Google>.

=cut

package Net::Google::Spelling;
use strict;

use Carp;
use Exporter;

$Net::Google::Spelling::VERSION   = 0.1;
@Net::Google::Spelling::ISA       = qw (Exporter);
@Net::Google::Spelling::EXPORT    = qw ();
@Net::Google::Spelling::EXPORT_OK = qw ();

=head1 Class Methods

=head2 $pkg = Net::Google::Spelling->new($service,\%args)

Where I<$service> is a valid I<GoogleSearchService> object.

Valid arguments are :

=over

=item B<key>

String. Google API key. If none is provided then the key passed to the parent I<Net::Google> object will be used.

=item B<phrase>

String or array reference.

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

  if ($args->{'phrase'}) {
    defined($self->phrase( (ref($args->{'phrase'}) eq "ARRAY") ? @{$args->{'phrase'}} : $args->{'phrase'} )) || return 0;
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

=head2 $pkg->phrase(@words)

Add one or more words to the phrase you want to spell-check.

If the first item in I<@words> is empty, then any existing I<phrase> data will be removed before the new data is added.

Returns a string. Returns undef if there was an error.

=cut

sub phrase {
  my $self  = shift;
  my @words = @_;

  if ((scalar(@words) > 1) && ($words[0] == "")) {
    $self->{'_phrase'} = [];
  }

  if (@words) {
    push @{$self->{'_phrase'}} , @words;
  }

  return join("",@{$self->{'_phrase'}});
}

=head2 $pkg->suggest()

Fetch the spelling suggestion from the Google servers.

Returns a string. Returns undef if there was an error.

=cut

sub suggest {
  my $self = shift;
  return $self->{'_service'}->doSpellingSuggestion(
						   $self->key(),
						   $self->phrase(),
						  );
}

=head1 VERSION

0.1

=head1 DATE

April 14, 2002

=head1 AUTHOR

Aaron Straup Cope

=head1 SEE ALSO

L<Net::Google>

=head1 LICENSE

Copyright (c) 2002, Aaron Straup Cope. All Rights Reserved.

This is free software, you may use it and distribute it under the same terms as Perl itself.

=cut

return 1;

}
