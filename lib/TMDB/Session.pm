package TMDB::Session;

#######################
# LOAD CORE MODULES
#######################
use strict;
use warnings FATAL => 'all';
use Carp qw(croak carp);

#######################
# LOAD CPAN MODULES
#######################
use Encode qw();
use LWP::UserAgent;
use JSON::Any;

#######################
# PUBLIC METHODS
#######################

## Constructor
sub new {
    my $class = shift;
    my $args  = shift;

    my $self = {};
    bless $self, $class;
    return $self->_init($args);
} ## end sub new

## Talk
sub talk {
    my $self = shift;
    my $args = shift;

    my $get = join( '/',
        $self->api_url, $self->api_version, $args->{method},
        $self->lang,    $self->api_type,    $self->api_key,
        $args->{params} );

    my $response = $self->ua->get($get);
    return unless $response->is_success();

    my $perl_ref =
        JSON::Any->new()
        ->Load(
        Encode::encode( 'utf-8-strict', $response->decoded_content ) );
    return if not $perl_ref->[0];
    return if ( $perl_ref->[0] =~ /nothing\s*found/ix );
    return $perl_ref;
} ## end sub talk

## Accessors
sub api_key     { return shift->{_api_key}; }
sub api_type    { return shift->{_api_type}; }
sub api_url     { return shift->{_api_url}; }
sub api_version { return shift->{_api_version}; }
sub lang        { return shift->{_lang}; }
sub ua          { return shift->{_ua}; }

#######################
# PRIVATE METHODS
#######################

## Initialize
sub _init {
    my $self = shift;
    my $args = shift;

    # Default User Agent
    my $ua = LWP::UserAgent->new( agent => "perl-tmdb/" . $args->{_VERSION} );

    # Required Args
    $self->{_api_key} = $args->{api_key} || croak "API key is not provided";

    # Optional Args
    $self->{_ua}   = $args->{ua}   || $ua;      # UserAgent
    $self->{_lang} = $args->{lang} || 'en-US';  # Language

    # Check user agent
    croak "LWP::UserAgent expected"
        unless $self->{_ua}->isa('LWP::UserAgent');

    # API settings
    $self->{_api_url}     = 'http://api.themoviedb.org';  # Base URL
    $self->{_api_version} = '2.1';                        # Version
    $self->{_api_type}    = 'json';                       # Always use JSON

    return $self;
} ## end sub _init

#######################
1;
