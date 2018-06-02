#! /usr/bin/perl
# 统计日志本标签信息
# 输入参数：日记本根目录, 更新或新建, 具体标签
# 详情见末尾的文档

package tagdb;
use strict;
use warnings;

use File::Find;
use File::Spec;
use File::Basename;

use FindBin qw($Bin);
use lib "$Bin";
use NoteBook;
use commsub;

my $DEBUG = 1;
my $outtime = 0;
my %records = ();

##-- 主函数 --##
sub main
{
	NoteBook::ParseArgv(@_);

	if (!$NoteBook::update || not -e $NoteBook::tagdb) {
		find(\&want_all, $NoteBook::tagdir);
		&create(\%records);
	}
	elsif (@NoteBook::update) {
		my $tagname = shift(@NoteBook::update);
		my $tagfile = File::Spec->catfile($NoteBook::tagdir, "$tagname.tag");
		record($tagfile)
		&update(\%records, 0);
	}
	else {
		my @infold = stat($NoteBook::tagdb);
		$outtime = $infold[9];
		find(\&want_new, $NoteBook::tagdir);
		&update(\%records, 0);
	}
}

##-- 子函数 --##

# 重建信息库文件
sub create(\%)
{
	my ($records) = @_;
	return unless %$records;

	open(my $fh, '>', $NoteBook::tagdb) or die "cannot open $NoteBook::tagdb $!";
	foreach my $tag (sort(keys(%$records))) {
		print $fh "$records->{$tag}\n";
	}
	close($fh);
	
	wlog("create tag.db") if $DEBUG;
}

# 更新信息库文件
# 参数二 $append 指示是否添加方式，在原笔记数量基础上增加
# 否则直接用 %$records 中的数量覆盖
sub update(\%$)
{
	my ($records, $append) = @_;
	return unless %$records; # 空列表

	# 读入旧文件
	my $content = readfile($NoteBook::tagdb);

	# 更新原有标签行
	foreach my $line (@$content) {
		my @fields = split("\t", $line);
		next if scalar(@fields) < 1;
		my $tagname = $fields[0];
		if (exists($records->{$tagname})) {
			if ($append) {
				my @new_fields = split("\t", $records->{$tagname});
				$fields[1] += $new_fields[1];
				$fields[2] = $new_fields[2];
				$line = join("\t", @fields);
			}
			else {
				$line = $records->{$tagname};
			}
			delete($records->{$tagname});
		}
	}
	
	# 添加新行，并重排序
	if (%$records) {
		foreach my $tagname (keys(%$records)) {
			push(@$content, $records->{$tagname});
		}
		@$content = sort(@$content);
	}

	# 重新写入
	writefile(@$content, $NoteBook::tagdb, 0);

	wlog("update tag.db") if $DEBUG;
}

# 输出所有标签信息
sub want_all
{
	return if !/\.tag$/i;
	my $name = $File::Find::name;
	&record($name);
}

# 只输出更新的标签
sub want_new
{
	return if !/\.tag$/i;

	my $name = $File::Find::name;
	my @info = stat($name);
	my $mtime = $info[9];
	return if $mtime < $outtime;

	&record($name);
}

# 获取一个标签的信息
sub record
{
	my $tagfile = shift;
	my $tagname = $tagfile;
	$tagname =~ s/^$NoteBook::tagdir.(.+)\.tag$/$1/;

	my $n = 0;
	open(my $fh, '<', $tagfile) or die "cannot open $tagfile $!";
	while (<$fh>) {
		$n++;
	}
	close($fh);

	my @info = stat($tagfile);
	my $mtime = $info[9];

	my $entry = "$tagname\t$n\t$mtime";
	$records{$tagname} = $entry;
}

&main(@ARGV) unless defined caller;
1;
__END__

=pod md
# 用法

```
tagdb.pl bookdir action tagname
```

1. bookdir: 笔记本根目录，默认为当前路径，也可用点（.）表示当前路径
2. action:  update|create 默认为更新，或提供参数表示重建，可简写 u|c
3. tagname: 当更新模式（u）时，只更新这个标签

输出文件保存在 `$bookdir/t/tag.db` 中，如果采用更新模式，则比较该文件
与 `t/*.tag` 各标签文件的修改时间，只扫描新修改过的标签文件。

元数据文件 `tag.db` 也是纯文本文件，每行分三个域，以制表符隔开，形如：

```
标签名 \t 使用该标签的笔记数量 \t 该标签的最近更新时间戳
```

=cut
