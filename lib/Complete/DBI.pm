package Complete::DBI;

# AUTHORITY
# DATE
# DIST
# VERSION

use 5.010001;
use strict;
use warnings;
use Log::ger;

use Complete::Common qw(:all);

use Exporter 'import';
our @EXPORT_OK = qw(
                       complete_dbi_dbd
                       complete_dbi_dsn
               );

our %SPEC;

$SPEC{complete_dbi_dbd} = {
    v => 1.1,
    summary => 'Complete from list of installed Perl DBI DBD drivers',
    args => {
        word => {
            schema => 'str*',
            req => 1,
            pos => 0,
        },
    },
    result_naked => 1,
};
sub complete_dbi_dbd {
    require Complete::Module;

    my %args = @_;
    my $word = $args{word} // '';

    Complete::Module::complete_module(
        word  => $word,
        find_pod => 0,
        find_prefix => 0,
        ns_prefix => 'DBD',
    );
}

$SPEC{complete_dbi_dsn} = {
    v => 1.1,
    summary => 'Complete DBI DSN string',
    args => {
        word => {
            schema => 'str*',
            req => 1,
            pos => 0,
        },
    },
    result_naked => 1,
};
sub complete_dbi_dsn {
    require Complete::Sequence;
    require Complete::Util;

    my %args = @_;
    my $word = $args{word} // '';

    Complete::Sequence::complete_sequence(
        word => $word,
        sequence => [
            "dbi:",
            # list of supported dbd's
            ["SQLite", "mysql"],
            ":",
            sub {
                my $stash = shift;
                my $driver = $stash->{completed_item_words}[1];
                my $cur_word = $stash->{cur_word};
                if ($driver eq 'SQLite') {
                    return Complete::Sequence::complete_sequence(
                        word => $cur_word,
                        sequence => [
                            {
                                alternative => [
                                    {
                                        sequence=>[
                                            "dbname=",
                                            # XXX complete_file + ":memory:"
                                        ],
                                    },
                                ]
                            }
                        ],
                    );
                } elsif ($driver eq 'mysql') {
                    return Complete::Sequence::complete_sequence(
                        word => $cur_word,
                        sequence => [
                            {
                                alternative => [
                                    {
                                        sequence=>[
                                            "database=",
                                            # XXX complete_list of databases
                                        ],
                                    },
                                    {
                                        sequence=>[
                                            "host=",
                                            # XXX complete_list of hosts
                                        ],
                                    },
                                    {
                                        sequence=>[
                                            "port=",
                                            # XXX complete_list of hosts
                                        ],
                                    },
                                ]
                            }
                        ],
                    );
                } else {
                    return [];
                }
            },
        ],
    );
}

1;
#ABSTRACT:

=head1 SYNOPSIS

 use Complete::DBI qw(
     complete_dbi_dbd
 );

 my $res = complete_dbi_dbd(word => '');
 # -> ['Pg', 'SQLite', 'mysql']
