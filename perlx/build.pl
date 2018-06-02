#! /usr/bin/perl
# 以重建方式调用 notdb.pl
use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin";
require "notedb.pl";

my $basedir = shift || '.';
&notedb::main($basedir, 'create');

print 'build success.';
