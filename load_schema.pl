#!/usr/bin/env perl

use strict;
use warnings;
use feature qw(say);

use File::Find qw(finddepth);
use File::Slurp qw(slurp);
use JSON;
use JSV::Validator;

sub init {
    my $base_dir = shift;

    my $validator = JSV::Validator->new;

    finddepth(+{
        wanted => sub {
            my $entry = $_;
            return unless (-f $entry && $entry =~ m/\.json$/);

            my $schema;
            eval {
                my $json = slurp($entry);
                $schema = decode_json($json);
            };
            if (my $e = $@) {
                return;
            }

            my $id = $schema->{id};

            $validator->register_schema($id => $schema);
        },
        bydepth => 1,
        no_chdir => 1,
    }, $base_dir);

    return $validator;
}

init("./schema");
