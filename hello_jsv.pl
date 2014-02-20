#!/usr/bin/env perl

use strict;
use warnings;
use feature qw(say);

use Data::Dumper qw(Dumper);
use JSON;
use JSV::Validator;

my $instance = {
  id       => 501566911, 
  name     => "Toru Yamaguchi", 
  birthday => "1976-12-24",
};

my $schema = decode_json(<< 'JSON');
{
  "type": "object",
  "properties": {
    "id": {
      "type": "integer",
      "minimum": 0
    },
    "name": { "type": "string" },
    "birthday": { 
      "type": "string",
      "format": "date"
    }
  }
}
JSON

my $validator = JSV::Validator->new;
my $result = $validator->validate($schema, $instance);

if ($result) {
    say "valid";
}
else {
    say Dumper($result);
}
