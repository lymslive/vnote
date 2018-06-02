#! /usr/bin/perl
# 一些通用的辅助函数

package commsub;
use Exporter 'import';
@EXPORT = qw(writefile readfile wlog subdir);

use strict;
use warnings;

# 写文本文件，内容先保存在列表中，每行内容本身不应有换行符
# 第三参数可选，指定以 >> 的方式附加文件
# 须调用者保证父目录存在
sub writefile(\@$$)
{
	my ($content, $file, $append) = @_;
	my $fh;
	if (defined $append && $append) {
		open($fh, '>>', $file) or die "cannot open $file $!";
	}
	else {
		open($fh, '>', $file) or die "cannot open $file $!";
	}
	foreach my $line (@$content) {
		print $fh "$line\n";
	}
	close($fh);
}

# 读文本文件，返回每行文本组成的列表
sub readfile($)
{
	my $file = shift;
	open(my $fh, '<', $file) or die "cannot open $file $!";
	my @content = <$fh>;
	chomp(@content);
	close($fh);
	return \@content;
}

# 打印日志
sub wlog(@)
{
	my $msg = join(" ", @_);
	my ($package, $filename, $line) = caller;
	my $logstr = "[$package] $filename:$line | $msg";
	print STDERR "$logstr\n";
	1; # always true
}

# 获取子目录名列表
sub subdir($)
{
	my $dir = shift;
	# wlog "$dir";
	opendir(my $dh, $dir) or die "cannot opendir $dir: $!";
	my @subdir = grep {!/^\./ && -d File::Spec->catfile($dir, $_)} readdir($dh);
	closedir($dh);
	# wlog @subdir;
	return @subdir;
}

1;
__END__
