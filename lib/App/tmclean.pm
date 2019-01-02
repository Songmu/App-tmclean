package App::tmclean;
use 5.010;
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

sub logf {
    my $msg = shift;
       $msg = sprintf($msg, @_);
    my $prefix = '[tmclan]' . Time::Piece->localtime->strftime('[%Y-%m-%d %H:%M:%S] ');
    $msg .= "\n" if $msg !~ /\n$/;
    print STDERR $prefix . $msg;
}

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

    # XXX needs check sudo?
    $self->cmd('tmutil', 'stopbackup');
    $self->cmd('tmutil', 'disable'); # need sudo

    my @targets = $self->backups2delete;
    use Data::Dumper;
    warn Dumper \@targets;
}

sub backups2delete {
    my $self = shift;
    my @backups = `tmutil listbackups`;
    if ($? != 0) {
        die "failed to execute `tmutil listbackups`: $?\n";
    }
    # e.g. /Volumes/Time Machine Backup/Backups.backupdb/$machine/2018-01-07-033608
    return grep {
        chomp;
        my @paths = split m!/!, $_;
        my $backup_date = Time::Piece->strptime($paths[-1], '%Y-%m-%d-%H%M%S');
        $self->before_tp > $backup_date;
    } @backups;
}

sub before_tp {
    my $self = shift;

    $self->{before_tp} ||= sub {
        if ($self->before) {
            my $time = str2time $self->before; # str2time parses the time as localtime
            die "unrecognized date format @{[$self->before]}" unless $time;
            return Time::Piece->localtime($time);
        }
        my $days = $self->days || 366;
        return Time::Piece->localtime() - Time::Seconds::ONE_DAY() * $days;
    }->();
}

sub cmd {
    my ($self, @command) = @_;

    my $cmd_str = join(' ', @command);
    logf 'execute%s: `%s`', $self->dry_run ? '(dry-run)' : '', $cmd_str;
    if (!$self->dry_run) {
        !system(@command) or die "failed to execute command: $cmd_str: $?\n";
    }
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

