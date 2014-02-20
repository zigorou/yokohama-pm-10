#!/usr/bin/env perl

use strict;
use warnings;
use feature qw(say);

use Data::Dumper qw(Dumper);
use File::Slurp qw(slurp);
use JSON;
use JSV::Validator;

my $json = JSON->new->allow_nonref(1);
my $jsv  = JSV::Validator->new;
my $schema_json = slurp($ARGV[0]);

my $schema = $json->decode($schema_json);
my $instance = $json->decode(do {
    local $/;
    <STDIN>
});

my $result = $jsv->validate($schema, $instance);

if ($result) {
    say "valid";
}
else {
    say Dumper($result);
}
