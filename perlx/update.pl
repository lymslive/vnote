#! /usr/bin/perl
# 以时间更新方式调用 notdb.pl
use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin";
require "notedb.pl";

my $basedir = shift || '.';
&notedb::main($basedir, 'update');

print 'update success.';
