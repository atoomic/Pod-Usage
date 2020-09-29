package inc::MyDistMakeMaker;

use strict;
use warnings;
use Moose;

extends 'Dist::Zilla::Plugin::MakeMaker::Awesome';

around _build_MakeFile_PL_template => sub {
    my $orig = shift;
    my $self = shift;

    my $content = $self->$orig(@_);

    my ( $start, $end ) = split( /^WriteMakefile/m, $content );

    my $custom = <<'CUSTOM';

# adjust EXE_FILES for VMS
if ( $^O eq 'VMS' ) {
  $WriteMakefileArgs{EXE_FILES} = [ map { "$_.com" } @{ $WriteMakefileArgs{EXE_FILES} } ];
  $WriteMakefileArgs{clen}->{FILES} = [ join " ", map { "$_.com" } @{ $WriteMakefileArgs{EXE_FILES} } ];
}

CUSTOM

    return "$start\n# <CUSTOM>\n $custom\n# </CUSTOM>\n \nWriteMakefile$end";
};

override _build_WriteMakefile_args => sub {

    my $args = super();
    my $to_clean = join( ' ', @{ $args->{EXE_FILES} } );

    return +{
        %$args,
        clean        => { FILES => $to_clean },
        PL_FILES => { 'scripts/pod2usage.PL' => 'scripts/pod2usage' }
    };
};

__PACKAGE__->meta->make_immutable;