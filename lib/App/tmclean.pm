package App::tmclean;
use strict;
use warnings;
use Getopt::Long qw/GetOptions :config posix_default no_ignore_case bundling auto_help/;
use Pod::Usage qw/pod2usage/;
use Hash::Rename qw/hash_rename/;
use Class::Accessor::Lite (
    new => 1,
    ro  => [qw/before days dry_run/],
);
use HTTP::Date qw/str2time/;
use Time::Piece ();
use Time::Seconds ();

our $VERSION = "0.01";

sub new_with_options {
    my ($class, @argv) = @_;

    my ($opt) = $class->parse_options(@argv);
    $class->new($opt);
}

sub parse_options {
    my ($class, @argv) = @_;

    local @ARGV = @argv;
    GetOptions(\my %opt, qw/
        days=i
        before=s
        dry-run
    /) or pod2usage(2);

    hash_rename %opt, code => sub {tr/-/_/};
    return (\%opt, \@ARGV);
}

sub run {
    my $self = shift;
    print $self->before_tp . "\n";
}

sub before_tp {
    my $self = shift;

    if ($self->before) {
        my $time = str2time $self->before; # str2time parses the time as localtime
        die "unrecognized date format @{[$self->before]}" unless $time;
        return Time::Piece->localtime($time);
    }
    my $days = $self->days || 366;
    return Time::Piece->localtime() - Time::Seconds::ONE_DAY() * $days;
}

1;
__END__
=for stopwords tmclean

=encoding utf-8

=head1 NAME

App::tmclean - backend class of tmclean

=head1 SYNOPSIS

    use App::tmclean;

=head1 DESCRIPTION

App::tmclean is backend module of L<tmclean>.

=head1 LICENSE

Copyright (C) Songmu.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Songmu E<lt>y.songmu@gmail.comE<gt>

=cut

