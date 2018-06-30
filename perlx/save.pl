#! /usr/bin/perl
# 保存一条笔记
# 参数一：日记本目录
# 参数二：笔记ID
# 从标准输入获取笔记的前两行，主要用于 vnote 调用
use strict;
use warnings;

use File::Spec;
use File::Basename;
use File::Path qw(make_path remove_tree);
use FindBin qw($Bin);
use lib "$Bin";
use NoteBook;
use commsub;

my $DEBUG = 1;
##-- MAIN --##
sub main
{
	my ($bookdir, $noteid) = @_;
	$bookdir = $ENV{PWD} unless defined $bookdir;
	$bookdir = $ENV{PWD} if $bookdir eq '.';

	die "incorrect note name format: $noteid" unless $noteid =~ /(\d{4})(\d\d)(\d\d)_\d+/;
	my ($y, $m, $d) = ($1, $2, $3);

	# 提取日志信息
	my ($title, $tagline);
	defined($title = <STDIN>) or die 'cannot read title line';
	chomp($title);
	$title =~ s/^[\s#]*//;

	defined($tagline = <STDIN>) or die 'cannot read tag line';
	chomp($tagline);
	my @tags = $tagline =~ m/`([^`]+)`/g;

	@tags = grep {!/^\s*$/ && !/^[+-]$/} @tags;
	@tags = map(lc, @tags);
	my $tags = join("|", @tags);
	my $entry = "$noteid\t$title\t[$tags]";
	wlog($entry) if $DEBUG;

	# 只为 NoteBook 的基础设施
	NoteBook::ParseArgv($bookdir, 'u', $noteid);

	# 维护 cache
	my @today = NoteBook::today();
	push_che(@today);
	my ($year, $month, $day) = @today;
	if ($y == $year && $m == $month && $d == $day) {
		update_che($NoteBook::day_che, $entry)
	}
	elsif ($y == $year && $m == $month) {
		update_che($NoteBook::month_che, $entry)
	}
	elsif ($y == $year) {
		update_che($NoteBook::year_che, $entry)
	}
	else {
		update_che($NoteBook::hist_che, $entry)
	}
	
	# 更新 tag 文件
	my %tag_has_new = ();
	foreach my $tag (@tags) {
		my $new = update_tag($tag, $entry);
		$tag_has_new{$tag} = 1 if $new;
	}
	update_tagdb(%tag_has_new);

	# 更新 datadb 统计
	update_datedb($y, $m, $d);
}

##-- SUBS --##

# 将缓存升级合并
sub push_che
{
	my ($year, $month, $day) = @_;
	my ($y, $m, $d) = NoteBook::datefile($NoteBook::year_che);
	merge_che($NoteBook::hist_che, $NoteBook::year_che) if $y < $year;
	($y, $m, $d) = NoteBook::datefile($NoteBook::month_che);
	merge_che($NoteBook::year_che, $NoteBook::month_che) if $m < $month;
	($y, $m, $d) = NoteBook::datefile($NoteBook::day_che);
	merge_che($NoteBook::month_che, $NoteBook::day_che) if $d < $day;
}

# 将低级缓存文件内容附加到高级缓存文件之末，低级文件内容清空，但文件保留
sub merge_che($$)
{
	my ($up, $low) = @_;
	my $content = readfile($low);

	open(my $fh, '>>', $up) or die "cannot open $up $!";
	foreach my $line (@$content) {
		print $fh "$line\n";
	}
	close($fh);

	open($fh, '>', $low) or die "cannot open $low $!";
	close($fh);
}

# 将一条记录更新到缓存文件，返回是否新增记录
sub update_che($$)
{
	my ($filename, $entry) = @_;
	wlog('update_che:', $filename) if $DEBUG;

	my ($noteid, $title, $tags) = split("\t", $entry);
	my $content = readfile($filename);

	my $found = 0;
	foreach my $line (@$content) {
		next unless $line =~ /^$noteid/;
		$line = $entry;
		$found = 1;
	}
	
	push(@$content, $entry) unless $found;
	writefile(@$content, $filename, 0);
	return 1 - $found;
}

# 更新一条记录到标签文件，可能自动创建子目录，返回是否新增记录
sub update_tag($$)
{
	my ($tagname, $entry) = @_;
	wlog('update_tag:', $tagname) if $DEBUG;

	my $tagfile = File::Spec->catfile($NoteBook::tagdir, "$tagname.tag");
	if ($tagname =~ m{/}) {
		my $partdir = dirname($tagname);
		my $fulldir = File::Spec->catdir($NoteBook::tagdir, split("/", $partdir));
		make_path($fulldir);
	}
	my $new = update_che($tagfile, $entry);
	return $new;
}

# 更新标签汇总文件
sub update_tagdb
{
	my %records = @_;
	return unless %records; # 空列表
	wlog('update_tagdb') if $DEBUG;

	# 读入旧文件
	my $content = readfile($NoteBook::tagdb);
	my $nowtime = time;

	# 更新原有标签行
	foreach my $line (@$content) {
		my @fields = split("\t", $line);
		next if scalar(@fields) < 1;
		my $tagname = $fields[0];
		if (exists($records{$tagname})) {
			my @new_fields = split("\t", $records{$tagname});
			$fields[1] += 1;
			$fields[2] = $nowtime;
			$line = join("\t", @fields);
			delete($records{$tagname});
		}
	}
	
	# 添加新行，并重排序
	if (%records) {
		foreach my $tagname (keys(%records)) {
			push(@$content, "$tagname\t1\t$nowtime");
		}
		@$content = sort(@$content);
	}

	# 重新写入
	writefile(@$content, $NoteBook::tagdb, 0);
}

# 更新日期统计文件
sub update_datedb
{
	my ($year, $month, $day) = @_;
	wlog('update_datedb') if $DEBUG;

	my $content = readfile($NoteBook::datedb);
	
	my $patten = File::Spec->catfile($NoteBook::datedir, $year, $month, $day, '*.md');
	my @note = glob($patten);
	my $num = scalar(@note);
	# wlog($num, @note);

	my ($ym, $numsum, $numsep);

	my $new = 1;
	my $modified = 0;
	my $yyyymm = "$year/$month";
	foreach my $line (@$content) {
		next unless $line =~ /^$yyyymm/;

		($ym, $numsum, $numsep) = split("\t", $line);
		my @numsep = split(",", $numsep);
		my $num_old = $numsep[+$day-1] || 0; 
		if ($num != $num_old) {
			$numsum += $num - $num_old;
			$numsep[+$day-1] = $num;
			
			$numsep = join(",", @numsep);
			$line = "$yyyymm\t$numsum\t$numsep";
			$modified = 1;
		}
		$new = 0;
		last;
	}

	if ($new) {
		$numsum = $num;
		my @numsep = ();
		$numsep[+$day-1] = $num;
		$numsep = join(",", @numsep);
		push(@$content, "$yyyymm\t$numsum\t$numsep");
		$modified = 1;
	}

	writefile(@$content, $NoteBook::datedb, 0) if $modified;
}

##-- END --##
&main(@ARGV) unless defined caller;
print "save success\n";
1;
__END__
