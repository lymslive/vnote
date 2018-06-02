#! /usr/bin/perl
# 创建或更新笔记本索引系统

package notedb;
use strict;
use warnings;
use File::Find;
use File::Spec;
use File::Basename;
use File::Path qw(make_path remove_tree);
use FindBin qw($Bin);
use lib "$Bin";
use NoteBook;
use commsub;
require "datedb.pl";
require "tagdb.pl";

my $DEBUG = 1;
my @records = ();
my @today;
my $last_time = 0;

# 受影响的标签，键是标签名，值是记录行列表引用
my %tags = ();

##-- 主函数 --##
sub main
{
	NoteBook::ParseArgv(@_);
	@today = NoteBook::today();

	if (!$NoteBook::update) {
		&create();
		&datedb::create();
	}
	elsif (@NoteBook::update) {
		&update_note(@NoteBook::update);
		# 在调用函数中处理了
		# &datedb::update(...) 的这种指定更新情况
	}
	else {
		&update_new();
		&datedb::update();
	}
	
	# 更新标签文件
	if (%tags) {
		&save_tag();
	}
}

##-- 子函数 --##

# 四级缓存设计
my ($fh_hist, $fh_year, $fh_month, $fh_day);
sub open_che($$)
{
	unless (-d $NoteBook::chedir) {
		mkdir($NoteBook::chedir) or die "cannot mkdir $NoteBook::chedir: $!";
	}
	
	my ($mode, $level) = @_;
	open($fh_day, $mode, $NoteBook::day_che) or die "cannot open $NoteBook::day_che: $!" if $level >= 1;
	open($fh_month, $mode, $NoteBook::month_che) or die "cannot open $NoteBook::month_che: $!" if $level >= 2;
	open($fh_year, $mode, $NoteBook::year_che) or die "cannot open $NoteBook::year_che: $!" if $level >= 3;
	open($fh_hist, $mode, $NoteBook::hist_che) or die "cannot open $NoteBook::hist_che: $!" if $level >= 4;
}
sub write_che($)
{
	my ($level) = @_;
	return if $level < 1;
	# 与今天日期比较写入不同缓存文件
	my ($year, $month, $day) = @today;
	my $patten = qr/^\s*(\d{4})(\d\d)(\d\d)_\d+/;
	foreach my $record (@records) {
		wlog("invalid record:", substr($record, 0, 10), "...") && next 
		unless $record =~ $patten;
		my ($y, $m, $d) = ($1, $2, $3);
		if ($y < $year && $level >= 4) {
			print $fh_hist "$record\n";
		}
		elsif ($m < $month && $level >= 3){
			print $fh_year "$record\n";
		}
		elsif ($d < $day && $level >= 2){
			print $fh_month "$record\n";
		}
		else{
			print $fh_day "$record\n";
		}
	}
}
sub close_che($)
{
	my ($level) = @_;
	close($fh_day)   if $level >= 1 ;
	close($fh_month) if $level >= 2;
	close($fh_year)  if $level >= 3;
	close($fh_hist)  if $level >= 4; 
}

# 重建笔记本所有记录
sub create
{
	find(\&want_all, $NoteBook::datedir);
	@records = sort(@records) if @records;
	open_che('>', 4);
	write_che(4);
	close_che(4);
}

# 更新笔记记录
sub update_new
{
	&check_che(); # 确定上次缓存时间
	my ($y, $m, $d) = NoteBook::ymdtime($last_time);
	my ($year, $month, $day) = @today;

	my $level = 1;
	$level++ if $d < $day;
	$level++ if $m < $month;
	$level++ if $y < $year;

	if ($level >= 4) {
		find(\&want_new, $NoteBook::datedir);
	}
	elsif ($level >= 3) {
		find(\&want_new, File::Spec->catdir($NoteBook::datedir, $year));
	}
	elsif ($level >= 2) {
		find(\&want_new, File::Spec->catdir($NoteBook::datedir, $year, $month));
	}
	else {
		find(\&want_new, File::Spec->catdir($NoteBook::datedir, $year, $month, $day));
	}
	
	@records = sort(@records) if @records;
	&push_che(); # 先检查合并缓存

	open_che('>>', $level);
	write_che($level);
	close_che($level);
}

# 只更新特定笔记，一般是当天最新的笔记
sub update_note
{
	my $noteid = shift;
	die "incorrect note name format: $noteid" unless $noteid =~ /(\d{4})(\d\d)(\d\d)_\d+/;
	my ($y, $m, $d) = ($1, $2, $3);
	my ($year, $month, $day) = @today;
	if ($d != $day || $m != $month || $y != $year) {
		wlog("not update today's single note, may be wrong!");
	}

	my $notepath = File::Spec->catfile($NoteBook::datedir, $y, $m, $d, "$noteid.md");
	my $entry = &record($notepath);
	push(@records, $entry);

	# 虽然通常情况下只更新最低级的缓冲，仍按统一方式处理
	my $level = 1;
	$level++ if $d < $day;
	$level++ if $m < $month;
	$level++ if $y < $year;
	&push_che(); 
	open_che('>>', $level);
	write_che($level);
	close_che($level);

	# 更新日期统计
	&datedb::update("$y/$m/$d");
}

# 提取所有笔记信息
sub want_all
{
	return if !/\.md$/i;
	my $name = $File::Find::name;
	my $entry = &record($name);
	push(@records, $entry);
}

# 只输出更新的笔记
sub want_new
{
	return if !/\.md$/i;

	my $name = $File::Find::name;
	my @info = stat($name);
	wlog("cannot stat($name)") && return unless @info;
	my $mtime = $info[9];
	return if $mtime < $last_time;

	my $entry = &record($name);
	push(@records, $entry);
}

# 获取一个笔记的信息，输入参数为笔记文件全路径，返回一行记录
sub record($)
{
	my $notefile= shift;
	my ($name, $dir, $suffix) = fileparse($notefile, ".md", ".MD");
	my $title = "";
	my @tags = ();

	# 不可读日记文件
	unless (-e $notefile && -r $notefile) {
		wlog("cannot read note: $notefile");
		return "$name\tInvalid Note File\t";
	}

	# 只读第一行标题与第二行标签
	open(my $fh, '<', $notefile) or die "cannot open $notefile $!";
	my $n = 0;
	while (<$fh>) {
		chomp;
		$n++;
		if ($n == 1) {
			($title = $_ ) =~ s/^[\s#]*//;
		}
		elsif ($n == 2) {
			@tags = $_ =~ m/`([^`]+)`/g;
		}
		else {
			last;
		}
	}
	close($fh);

	# 除去 `+` `-` 标签与空标签，统一小写
	@tags = grep {!/^\s*$/ && !/^[+-]$/} @tags;
	@tags = map(lc, @tags);
	my $tags = join("|", @tags);
	my $entry = "$name\t$title\t[$tags]";

	# 更新 tag 文件
	foreach my $tag (@tags) {
		update_tag($tag, $entry);
	}

	return $entry;
}

# 获取最近的缓存时间，一般是最低的 day.che, 除非文件不存在
# 时间保存在全局 $last_time 中，返回哪个缓存文件最新
sub check_che
{
	my @files = ($NoteBook::day_che, $NoteBook::month_che, $NoteBook::year_che, $NoteBook::hist_che);
	my $che;
	foreach my $file (@files) {
		my @info = stat($file);
		next unless @info;
		my $mtime = $info[9];
		if ($last_time < $mtime) {
			$last_time = $mtime;
			$che = $file;
			last; # 快速返回，低级缓存最新
		}
	}
	
	return $che;
}

# 将缓存升级合并
sub push_che
{
	my ($year, $month, $day) = @today;
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

# 更新标签文件，将 $entry 添加到 $tagname 名下
# 先保存内存列表，最后统一写文件
sub update_tag($$)
{
	my ($tagname, $entry) = @_;
	if (exists($tags{$tagname})) {
		push(@{$tags{$tagname}}, $entry);
	}
	else {
		$tags{$tagname} = [$entry];
	}
}

# 更新各标签文件
sub save_tag
{
	if (!$NoteBook::update && -d $NoteBook::tagdir) {
		&clear_tag();
	}

	unless (-d $NoteBook::tagdir) {
		mkdir($NoteBook::tagdir) or die "cannot mkdir $NoteBook::tagdir $!";
	}

	# 同时保存标签统计数据
	my %tagstate = ();
	my $nowtime = time;

	foreach my $tagname (keys %tags) {
		my $tagfile = File::Spec->catfile($NoteBook::tagdir, "$tagname.tag");
		if ($tagname =~ m{/}) {
			my $partdir = dirname($tagname);
			my $fulldir = File::Spec->catdir($NoteBook::tagdir, split("/", $partdir));
			make_path($fulldir);
		}
		writefile(@{$tags{$tagname}}, $tagfile, '>>');

		my $num = scalar(@{$tags{$tagname}});
		my $entry = "$tagname\t$num\t$nowtime";
		$tagstate{$tagname} = $entry;
	}

	# 更新 tag.db
	if (!$NoteBook::update) {
		tagdb::create(\%tagstate);
	}
	else {
		tagdb::update(\%tagstate, 1);
	}
}

# 清空所有旧标签，在重建时用到
sub clear_tag
{
	remove_tree($NoteBook::tagdir);
	mkdir($NoteBook::tagdir) or die "cannot mkdir $NoteBook::tagdir: $!";
}

##-- 尾语 --##
&main(@ARGV) unless defined caller;
1;
__END__

=pod

=head1 用法

生成或更新笔记本索引，以及标签与日期统计数据。

  notedb.pl bookdir update what

命令行可输入三个位置参数：

=over

=item * bookdir 
笔记本要目录，默认或点号 '.' 表示当前目录。

=item * update
默认按时间戳更新，'create' 或简写 'c' 表示重新生成。

=item * what 指定更新哪个笔记。参数是特殊格式的笔记 id C<yyyymmdd_n> 。
目前只支持一个更新参数，且一般是当天最新增的笔记。

=back

=head1 输出

在 C<bookdir/c> 目录维护四级索引，当天、当月、当年以及历史笔记索引。
分别以 C<day.che> C<month.che> C<year.che> C<hist.che> 命名。
都是文本文件格式，每行一个笔记记录，格式如下：

  yyyymmdd_n  笔记标题  [笔记标签组]

以制表符 C<\t> 分隔。行首是笔记 id，包含年月日等信息，中间是笔记标题，
末尾是可选的标签组，在中括号中再以竖线 C<|> 分隔每个标签。

例外，将在 C<bookdir/t> 目录下为每个标签生成一个 C<*.tag> 文件，
记录属于这个标签的笔记。每行的格式与上面的 C<*.che> 索引文件相同。

生成标签统计将调用 C<tagdb.pl>，生成日期统计将调用 C<datedb.pl> 。
后两个脚本也可以单独执行。

=head1 应用

可将这些脚本放在 C<bookdir/x> 中，从命令行直接运行，不定时手动更新。
也可以利用 C<vnote> 这个 vim 插件，在写笔记时自动调用脚本更新。
需要与该插件联用。这应该比直接纯用 vim script 实现会更快。

注意：如果提供第三参数，只有第一次保存更新时正确，因为为了效率是用
附加方式写文件的，当作最新笔记处理。如果重复保存更新，有可能生成重复
记录。故不适合让 vim 编辑中响应写入事件调用。

=cut
