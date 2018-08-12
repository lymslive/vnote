#! /usr/bin/perl
package stripraw;
use strict;
use warnings;

my @content = ();
my @break = ('</div>', '</p>', '</table>', '</tr>', '<br.*?>');
my $erase = '<.*?>';

##-- MAIN --##
sub main
{
	my @argv = @_;
	while (<>) {
		chomp;
		s/\s*$//;
		s/^\s*//;
		next unless $_;

		foreach my $br (@break) {
			s/$br/\n/g;
		}
		s/$erase//g;

		# save this to @content, may break into more lines
		/\n/ ? push(@content, split("\n", $_)) : push(@content, $_);
	}
	
	print "$_\n" foreach @content;
}

##-- SUBS --##

##-- END --##
&main(@ARGV) unless defined caller;
1;
__END__
提取 html 中的文本，简单地移除标签，将某些闭标签换为换行符。
