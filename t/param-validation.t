#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 6;
use Cwd;
use Proc::Daemon;
use AnyEvent;

use GRNOC::RabbitMQ::Client;

my $daemon = Proc::Daemon->new(
    work_dir => getcwd(),
    exec_command => 'perl listener.pl'
    );
my $pid = $daemon->Init();

sleep(5);

my $client = GRNOC::RabbitMQ::Client->new(
    topic => "Test.Data",
    exchange => "Test",
    user => "guest",
    pass => "guest"
    );

my $res = $client->plus(a=>1);
ok($res->{'error'}, "Missing parameter returns error");

$res = $client->plus(a=>1, b=>"foo");
ok($res->{'error'}, "Parameter doesn't match required pattern");

$res = $client->list_array(some_array => ["cat", "dog", "baby"]);
ok(scalar @{$res->{'results'}} == 3, "three elements in array");
ok((grep {$_ eq "cat"} @{$res->{'results'}}), "'cat' is in the the array");
ok((grep {$_ eq "dog"} @{$res->{'results'}}), "'dog' is in the array");
ok((grep {$_ eq "baby"} @{$res->{'results'}}), "'baby' is in the array");

$daemon->Kill_Daemon($pid);
