{

=head1 NAME

Net::Google::Search - simple OOP-ish interface to the Google SOAP API for searching

=head1 SYNOPSIS

 use Net::Google::Search;
 my $search = Net::Google::Search($service,\%args);

 $search->query(qw(aaron cope));
 map { print $_->title()."\n"; } @{$search->results()};

 # or

 foreach my $r (@{$search->response()}) {
   print "Search time :".$r->searchTime()."\n";

   # returns an array ref of Result objects
   # the same as the $search->results() method
   map { print $_->URL()."\n"; } @{$r->resultElement()}
 }

=head1 DESCRIPTION

Provides a simple OOP-ish interface to the Google SOAP API for searching.

This package is used by I<Net::Google>.

=cut

package Net::Google::Search;
use strict;

use Carp;
use Exporter;
use Net::Google::Response;

$Net::Google::Search::VERSION   = '0.4';
@Net::Google::Search::ISA       = qw (Exporter);
@Net::Google::Search::EXPORT    = qw ();
@Net::Google::Search::EXPORT_OK = qw ();

use constant RESTRICT_ENCODING => qw [ arabic gb big5 latin1 latin2 latin3 latin4 latin5 latin6 greek hebrew sjis euc-jp euc-kr cyrillic utf8 ];

use constant RESTRICT_LANGUAGES => qw [ ar zh-CN zh-TW cs da nl en et fi fr de el iw hu is it ja ko lv lt no pt pl ro ru es sv tr ];

use constant RESTRICT_COUNTRIES => qw [ AD AE AF AG AI AL AM AN AO AQ AR AS AT AU AW AZ BA BB BD BE BF BG BH BI BJ BM BN BO BR BS BT BV BW BY BZ CA CC CD CF CG CH CI CK CL CN CO CR CU CV CX CY CZ DE DJ DK DM DO DZ EC EE EG EH ER ES ET EU FI FJ FK FM FO FR FX GA GD GE GF GH GI GL GM GN GP GQ GR GS GT GU GW GY HK HM HN HR HT HU ID IE IL IO IQ IR IS IT JM JO JP KE KG KH KI KM KN KP KR KW KY KZ LA LB LC LI LK LR LS LT LU LV LY MA MC MD MG MH MK ML MM MN MO MP MQ MR MS MT MU MV MW MX MY MZ NA NC NE NF NG NI ML NO NP NR NU NZ OM PA PE PF PG PH PK PL PM PN PR PS PT PW PY QA RE RO RU RW SA SB SC SD SE SG SH SI SJ SK SL SM SN SO SR ST SV SY SZ TC TD TF TG TH TJ TK TM TN TO TP TR TT TV TW TZ UA UG UK UM US UY UZ VA VC VE VG VI VN VU WF WS YE YT YU ZA ZM ZR ];

use constant RESTRICT_TOPICS => qw [ unclesam linux mac bsd ];

use constant WATCH => "__estimatedTotalResultsCount";

=head1 OBJECT METHODS

=head2 $pkg = Net::Google::Search->new($service,\%args)

Where I<$service> is a valid I<GoogleSearchService> object.

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

  $self->{'_query'}       = [];
  $self->{'_lr'}          = [];
  $self->{'_restrict'}    = [];
  $self->{'_ie'}          = [];
  $self->{'_oe'}          = [];
  $self->{'_safe'}        = 0;
  $self->{'_filter'}      = 0;
  $self->{'_starts_at'}   = 0;
  $self->{'_max_results'} = 10;

  $self->starts_at(($args->{'starts_at'} || 0));
  $self->max_results(($args->{'max_results'}) || 10);

  if ($args->{lr}) {
    defined($self->lr( ((ref($args->{'lr'}) eq "ARRAY") ? @{$args->{'lr'}} : $args->{'lr'}) )) || return 0;
  }

  if ($args->{restrict}) {
    defined($self->restrict( ((ref($args->{'restrict'}) eq "ARRAY") ? @{$args->{'restrict'}} : $args->{'restrict'}) )) || return 0;
  }

  if ($args->{ie}) {
    defined($self->ie( ((ref($args->{'ie'}) eq "ARRAY") ? @{$args->{'ie'}} : $args->{'ie'}) )) || return 0;
  }

  if ($args->{oe}) {
    defined($self->oe( ((ref($args->{'oe'}) eq "ARRAY") ? @{$args->{'oe'}} : $args->{'oe'}) )) || return 0;
  }

  if (defined($args->{'filter'})) {
    defined($self->filter($args->{'filter'})) || return 0;
  }

  if (defined($args->{'safe'})) {
    defined($self->safe($args->{'safe'})) || return 0;
  }

  if (defined($args->{'starts_at'})) {
    defined($self->starts_at($args->{'starts_at'})) || return 0;
  }

  if (defined($args->{'max_results'})) {
    defined($self->max_results($args->{'max_results'})) || return 0;
  }

  return 1;
}

=head2 $pkg->key($key)

Returns a string.

Returns undef if there was an error.

=cut

sub key {
  my $self = shift;
  my $key  = shift;

  if (defined($key)) {
    $self->{'_key'} = $key;
  }

  return $self->{'_key'};
}

=head2 $pkg->query(@data)

If the first item in I<@data> is empty, then any existing I<query> data will be removed before the new data is added.

Returns a string of words separated by white space. Returns undef if there was an error.

=cut

sub query {
  my $self = shift;
  my @data = @_;

  if ((scalar(@data) > 1) && ($data[0] eq "")) {
    $self->{'_query'} = [];
  }

  if (@data) {
    push @{$self->{'_query'}}, @data;
  }

  return join(" ",@{$self->{'_query'}});
}

=head2 $pkg->starts_at($at)

Returns an int. Default is 0.

Returns undef if there was an error.

=cut

sub starts_at {
  my $self = shift;
  my $at   = shift;

  if (defined($at)) {
    $self->{'_starts_at'} = $at;
  }

  return $self->{'_starts_at'};
}

=head2 $pkg->max_results($max)

The default set by Google is 10 results. However, if you pass a number greater than 10 the I<results> method will make multiple calls to Google API.

Returns an int.

Returns undef if there was an error.

=cut

sub max_results {
  my $self = shift;
  my $max  = shift;

  if (defined($max)) {

    if (int($max) < 1) {
      carp "'$max' must be a int greater than 0";
      $max = 1;
    }

    $self->{'_max_results'} = $max;
  }

  return $self->{'_max_results'};
}

=head2 $pkg->restrict(@types)

If the first item in I<@types> is empty, then any existing I<restrict> data will be removed before the new data is added.

Returns a string. Returns undef if there was an error.

=cut

sub restrict {
  my $self  = shift;
  my @types = @_;

  if ((scalar(@types) > 1) && ($types[0] eq "")) {
    $self->{'_restrict'} = [];
    shift @types;
  }

  if (@types) {
    push @{$self->{'_restrict'}},@types;
  }
  
  return join("",@{$self->{'_restrict'}});
}

=head2 $pkg->filter($bool)

Returns true or false. Returns undef if there was an error.

=cut

sub filter {
  my $self = shift;
  my $bool = shift;

 
  if (defined($bool)) {
    $self->{'_filter'} = ($bool) ? 1 : 0;
  }

  return $self->{'_filter'};
}

=head2 $pkg->safe($bool)

Returns true or false. Returns undef if there was an error.

=cut

sub safe {
  my $self = shift;
  my $bool = shift;

  if (defined($bool)) {
    $self->{'_safe'} = ($bool) ? 1 : 0;
  }

  return $self->{'_safe'};
}

=head2 $pkg->lr(@lang)

Language restriction.

If the first item in I<@lang> is empty, then any existing I<lr> data will be removed before the new data is added.

Returns a string. Returns undef if there was an error.

=cut

sub lr {
  my $self = shift;
  my @lang = @_;

  if ((scalar(@lang) > 1) && ($lang[0] eq "")) {
    $self->{'_lr'} = [];
    shift @lang;
  } 

  if (@lang) {
    push @{$self->{'_lr'}},@lang;
  }
  
  return join("",@{$self->{'_lr'}});
}

=head2 $pkg->ie(@types)

Input encoding.

If the first item in I<@types> is empty, then any existing I<ie> data will be removed before the new data is added.

Returns a string. Returns undef if there was an error.

=cut

sub ie {
  my $self  = shift;
  my @types = @_;

  if ((scalar(@types) > 1) && ($types[0] eq "")) {
    $self->{'_ie'} = [];
    shift @types;
  }

  if (@types) {
    push @{$self->{'_ie'}},@types;
  }

  return join("",@{$self->{'_ie'}});
}

=head2 $pkg->oe(@types)

Output encoding.

If the first item in I<@types> is empty, then any existing I<oe> data will be removed before the new data is added.

Returns a string. Returns undef if there was an error.

=cut

sub oe {
  my $self  = shift;
  my @types = @_;

  if ((scalar(@types) > 1) && ($types[0] eq "")) {
    $self->{'_oe'} = [];
    shift @types;
  }

  if (@types) {
    push @{$self->{'_oe'}},@types;
  }

  return join("",@{$self->{'_oe'}});
}

=head2 $pkg->return_estimatedTotal($bool)

Toggle whether or not to return all the results defined by the '__estimatedTotalResultsCount' key.

Default is false.

=cut

sub return_estimatedTotal {
  my $self = shift;
  my $bool = shift;

  if (defined($bool)) {
    $self->{'__estimatedTotal'} = ($bool) ? 1 : 0;
  }

  return $self->{'__estimatedTotal'};
}

=head2 $pkg->response()

Returns an array ref of I<Net::Google::Response> objects, from which the search
response metadata as well as the search results may be obtained.

Use this method if you would like to receive a full response as documented
in the Google Web APIs Reference (the whole of section 3).

=cut

sub response {
  my $self = shift;

  if (defined($self->{'__state'}) &&
      ($self->{'__state'} eq $self->_state())) {

    return $self->{'__response'};
  }

  $self->{'__response'} = [];

  my $start_at  = $self->starts_at();
  my $to_fetch  = $self->max_results();

  while ($to_fetch > 0) {
    my $count = ($to_fetch > 10) ? 10 : $to_fetch;

    # Net::Google::Response will carp
    # if there's a problem so we just
    # move on if there's a problem.

    my $res = $self->_response($start_at,$count) || next;

    #

    if ((! $self->return_estimatedTotal()) && ($start_at >= $res->{__endIndex})) {
      last;
    }

    #

    if ($self->return_estimatedTotal()) {

      if (($self->{'__possible'} + scalar(@{$res->resultElements()})) >  $res->{'__estimatedTotalResultsCount'}) {

	my $justright = int($res->{'__estimatedTotalResultsCount'} - $self->{'__possible'});
	@{$res->resultElements()} = @{$res->resultElements()}[0..($justright -1)];

	push @{$self->{'__response'}} , $res;
	last;
      }

      $self->{'__possible'} += scalar(@{$res->resultElements()});

      if (($self->{'__possible'} + scalar(@{$res->resultElements()})) ==  $res->{'__estimatedTotalResultsCount'}) {
	last;
      }
    }

    #

    push @{$self->{'__response'}}, $res;

    $start_at += 10;
    $to_fetch -= 10;
  }

  return $self->{'__response'};
}

=head2 $pkg->results()

Returns an array ref of I<Result> objects (see docs for I<Net::Google::Response>), each of
which represents one result from the search.

Use this method if you don't care about the search response metadata, and only care about the
resources that are found by the search, as described in section 3.2 of the Google Web APIs Reference.

=cut

sub results {
  my $self = shift;
  return [ map { @{ $_->resultElements() } } @{$self->response()} ];
}

=head1 PRIVATE METHODS

=head2 $pkg->_response($first,$count)

=cut

sub _response {
  my $self  = shift;
  my $first = shift;
  my $count = shift;

  my $response = 
    $self->{'_service'}
      ->doGoogleSearch(
		       $self->key(),
		       $self->query(),
		       $first,
		       $count,
		       SOAP::Data->type(boolean=>($self->filter() 
						  ? "true" : "false")),
		       $self->restrict(),
		       SOAP::Data->type(boolean=>($self->safe() 
						  ? "true" : "false")),
		       $self->lr(),
		       $self->ie(),
		       $self->oe(),
		      );

  if (! $response) {
    return undef;
  }

  $self->{'__state'} = $self->_state();
  return Net::Google::Response->new($response);
}

=head2 $pkg->_state()

=cut

sub _state {
  my $self  = shift;
  my $state = undef;
  map {$state .= $self->$_()} qw (query lr restrict ie oe safe filter starts_at max_results);
  return $state;
}

=head1 VERSION

0.4

=head1 DATE

$Date: 2003/02/22 16:48:52 $

=head1 AUTHOR

Aaron Straup Cope

=head1 CONTRIBUTORS

Marc Hedlund <marc@precipice.org>

=head1 TO DO

=over 4

=item *

Add hooks to manage boolean searches and speacial query strings.

=back

=head1 SEE ALSO

L<Net::Google>

=head1 LICENSE

Copyright (c) 2002-2003, Aaron Straup Cope. All Rights Reserved.

This is free software, you may use it and distribute it under the same terms as Perl itself.

=cut

return 1;

}
