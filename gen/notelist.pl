#! /usr/bin/perl
# 列出目录下的日记文件及其第一行标题
# usage:
# alias nls='this file path'
# nls [day-path]

use strict;
use warnings;

# 这里 glob 要用 shell 的通配符规则，不是正式表达式
my $pattern = '[0-9]*_[0-9]*.*';
if (@ARGV > 0) {
	my $path = shift @ARGV;
	if ($path =~ '/$') {
		$pattern = "$path$pattern";
	}
	else {
		$pattern = "$path/$pattern";
	}
}

my @files = glob($pattern);
foreach my $file (@files) {
	open my $fh, '<', $file or die "cannot open file: $file";
	my $title = readline($fh);
	$title =~ s/^\s*#\s*//;
	print "$file\t$title";
	close $fh;
}

