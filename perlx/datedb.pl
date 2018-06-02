#! /usr/bin/perl

package datedb;
use strict;
use warnings;

use File::Spec;

use FindBin qw($Bin);
use lib "$Bin";
use NoteBook;
use commsub;

my $DEBUG = 1;

##-- 主函数 --##

sub main
{
	NoteBook::ParseArgv(@_);

	if (!$NoteBook::update || not -e $NoteBook::datedb) {
		&create();
	}
	else {
		&update(@NoteBook::update);
	}
}

##-- 子函数 --##

# 从头新建
sub create
{
	my @content = ();

	my @year = subdir($NoteBook::datedir);
	foreach my $year (@year) {
		my @month = subdir(File::Spec->catdir($NoteBook::datedir, $year));
		foreach my $month (@month) {
			my $entry = record_month($year, $month);
			push(@content, $entry);
		}
	}
	
	@content = sort(@content);
	writefile(@content, $NoteBook::datedb, 0);
	wlog("create new $NoteBook::datedb") if $DEBUG;
}

# 更新已有数据信息
sub update
{
	my @update = @_;
	my ($year, $month, $day);
	unless (@update) {
		($year, $month, $day) = NoteBook::today();
		wlog("update date.db since today") if $DEBUG;
	}
	else {
		# 只用第一个具体更新参数，要求满足 yyyy/mm/dd
		my $date = shift(@update);
		($year, $month, $day) = ($date =~ /\d+/g);
		wlog("update date.db since $date") if $DEBUG;
	}

	die "undefined year" unless defined $year;

	my $content = readfile($NoteBook::datedb);

	# 只更新一天数据
	if (defined $day) {
		wlog("update $year/$month/$day") if $DEBUG;
		my $new = update_day($content, $year, $month, $day);
		if ($new) {
			@$content = sort(@$content);
		}
	}
	# 更新一月
	elsif (defined $month) {
		wlog("update $year/$month") if $DEBUG;
		my $new = update_month($content, $year, $month);
		if ($new) {
			@$content = sort(@$content);
		}
	}
	# 更新一年
	else {
		wlog("update $year") if $DEBUG;
		my @month = subdir(File::Spec->catdir($NoteBook::datedir, $year));
		my $needsort = 0;
		foreach my $month (@month) {
			my $new = update_month($content, $year, $month);
			$needsort = 1 if $new;
		}
		if ($needsort) {
			@$content = sort(@$content);
		}
	}
	
	writefile(@$content, $NoteBook::datedb, 0);
}

# 分析一个月的笔记记录
sub record_month($$)
{
	my ($year, $month) = @_;
	my $numsum = 0;
	my @numsep = ();

	my $ympath = File::Spec->catdir($NoteBook::datedir, $year, $month);
	my $days = NoteBook::endday($year, $month);
	foreach my $d (1 .. $days) {
		my $day = sprintf("%02d", $d);
		my $patten = File::Spec->catfile($ympath, $day, '*.md');
		my @note = glob($patten);
		my $num = scalar(@note);
		$numsum += $num;
		$numsep[$d-1] = $num;
	}

	my $numsep = join(",", @numsep);
	my $yyyymm = "$year/$month";
	return "$yyyymm\t$numsum\t$numsep";
}

# 更新一个月的记录
# 返回是否增加了新行，需要重排序
sub update_month(\@$$)
{
	my ($content, $year, $month) = @_;
	my $entry = record_month($year, $month);
	my $new = 1;
	my $yyyymm = "$year/$month";
	foreach my $line (@$content) {
		next unless $line =~ /^$yyyymm/;
		$line = $entry;
		$new = 0;
		last;
	}
	push(@$content, $entry) if $new;
	return $new;
}

# 更新一天的记录
sub update_day(\@$$$)
{
	my ($content, $year, $month, $day) = @_;

	my $patten = File::Spec->catfile($NoteBook::datedir, $year, $month, $day, '*.md');
	my @note = glob($patten);
	my $num = scalar(@note);
	# wlog($num, @note);

	my ($ym, $numsum, $numsep);

	my $new = 1;
	my $yyyymm = "$year/$month";
	foreach my $line (@$content) {
		next unless $line =~ /^$yyyymm/;

		($ym, $numsum, $numsep) = split("\t", $line);
		my @numsep = split(",", $numsep);
		$numsum += $num - $numsep[+$day-1];
		$numsep[+$day-1] = $num;

		$numsep = join(",", @numsep);
		$line = "$yyyymm\t$numsum\t$numsep";
		$new = 0;
		last;
	}

	if ($new) {
		$numsum = $num;
		my @numsep = ();
		$numsep[+$day-1] = $num;
		$numsep = join(",", @numsep);
		push(@$content, "$yyyymm\t$numsum\t$numsep");
	}
	return $new;
}

&main(@ARGV) unless defined caller;
1;
__END__
=pod
# 用法

```
datadb.pl bookdir action date
```

参数意义同 `tagdb.pl`。

默认当前路径作为笔记本根目录，更新当前月的笔记总数，用参数 `c` 重建。
输出文件在 `$bookdir/d/date.db`。每行两个域，形如：
```
yyyy/mm \t 该月的笔记总量 \t 每天的笔记量
```

* 年月固定用 / 分隔，不依赖于操作系统分隔符
* 每天的笔记量用一个长串的以 , 分隔的数字列表，表示当前第天的数量，可能很多 0

```
$day:$num,$day:$num
```

其中月名与天名，都是两位数字，与目录命名同规则，可能含有前导 0 。

在更新模式中，省略参数时默认更新今天日期。否则参数可指定 yyyy/mm/dd 
格式，可以省略 dd 或 mm 只指定更大范围的日期。

=cut
