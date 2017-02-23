#! /usr/bin/perl
# 生成示例日记本库
# 按日期生成目录结构，每篇日记只有标题与标签，可用于测试日记管理工具
# 简单地随机生成单词

use strict;
use warnings;

#========= 基础配置 =======#
my $rootdir = "_box";
my $begin_year = 2000;
my $end_year = 2010;
my $note_per_day = 10;
my $title_length = 16;

# 日记标签与路径名
my @note_tags = ();
my $note_tags_num = 100; # 预设标签个数
my @note_paths = ();
my $note_path_depth = 3; # 路径最大深度
my $note_path_width = 5; # 每个路径的子目录数
# 每篇日志赋于几个标签与路径
my $tag_per_note = 3;
my $path_per_note = 2;

# 每月的天数
my @end_days = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

# 随机单词所取的字母
my @letter = qw(a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z);

#========= 过程控制调用 =======#

if (@ARGV > 0) {
	$rootdir = shift @ARGV;
}

PreGenerateTags();
# Debug_SeeTags();
GenerateBox();

#========= 子过程 =======#

# 预生成标签与路径标签
sub PreGenerateTags
{
	# 平凡标签
	for (my $var = 0; $var < $note_tags_num; $var++)
	{
		my $tag = RandWord();
		push @note_tags, $tag;
	}
	
	# 第一层子目录
	for (my $var = 0; $var < $note_path_width; $var++)
	{
		my $tag = RandWord();
		push @note_paths, $tag;
	}

	# 扩展下层目录，广度优先，全部压入 @note_paths
	my $old_beg_index = 0;
	for (my $depth = 1; $depth < $note_path_depth; $depth++)
	{
		my $old_end_index = $#note_paths;
		for (my $i = $old_beg_index; $i <= $old_end_index; $i++)
		{
			my $pre_path = $note_paths[$i];
			for (my $j = 0; $j < $note_path_width; $j++)
			{
				my $tag = RandWord();
				$tag = $pre_path . '/' . $tag;
				push @note_paths, $tag;
			}
		}
		$old_beg_index = $old_end_index + 1;
	}
}

sub Debug_SeeTags
{
	open my $TAG_FILE, ">", "$rootdir/note_tags.txt" or die "can't open tag file";
	foreach my $tag (@note_tags)
	{
		print $TAG_FILE "$tag\n";
	}
	close $TAG_FILE;
	
	open my $PATH_FILE, ">", "$rootdir/note_paths.txt" or die "can't open tag file";
	foreach my $tag (@note_paths) {
		print $PATH_FILE "$tag\n";
	}
	close $PATH_FILE;
}

# 生成日记目录结构，按年月日
sub GenerateBox
{
	mkdir $rootdir unless -d $rootdir;

	my $datedir = "$rootdir/d";
	my $path = $datedir;
	mkdir $path unless -d $path;

	for my $year ($begin_year ... $end_year)
	{
		$path = "$datedir/$year";
		mkdir $path unless -d $path;

		for my $month (1 ... 12)
		{
			$month = "0$month" if $month < 10;
			$path = "$datedir/$year/$month";
			mkdir $path unless -d $path;

			my $end_day = $end_days[$month-1];

			# 闰年二月
			if ($month == 2 && ($year % 4 == 0 && $year % 100 != 0 || $year % 400 == 0))
			{
				++$end_day;
			}

			for my $day (1 ... $end_day)
			{
				$day = "0$day" if $day < 10;
				$path = "$datedir/$year/$month/$day";
				mkdir $path unless -d $path;

				for my $seqno (1 ... $note_per_day)
				{
					# 拼接文件名
					my $title = RandWord($title_length);
					# my $file = "${year}${month}${day}_${seqno}_${title}";
					# 改为：文件名中不必嵌入标题了
					my $file = "${year}${month}${day}_${seqno}";
					my $file_path = "$path/$file" . '.md';
					# 一半概率为私有日记，文件名末尾附减号 -
					if (int(rand(2)) == 1) 
					{
						$file_path = "$path/$file" . '-.md';
					}
					# 生成一篇日记
					GenerateNote($file_path, $title);
				}

			}
		}
	}
}

sub GenerateNote
{
	my $file_path = shift;
	my $title = shift;

	print "GenerateNote: $file_path\n";

	open my $NOTE_FILE, ">", $file_path or die "can not open file: $file_path";

	# 标题
	my $title_line = "# $title\n";
	print $NOTE_FILE $title_line;

	# 标签
	for (my $i = 0; $i < $tag_per_note; $i++) {
		my $index = int(rand(scalar @note_tags));
		my $tag = $note_tags[$index];
		print $NOTE_FILE "`$tag` ";
	}
	print $NOTE_FILE "\n";
	
	# 路径
	for (my $i = 0; $i < $path_per_note; $i++) {
		my $index = int(rand(scalar @note_paths));
		my $tag = $note_paths[$index];
		print $NOTE_FILE "`$tag` ";
	}
	print $NOTE_FILE "\n";
	
	# 内容
	print $NOTE_FILE "\n";
	print $NOTE_FILE "Note content go below ...";

	close $NOTE_FILE;
}

# 随机生成一个单词，参数为平均长度，默认10
sub RandWord
{
	my $avg_length = shift;
	if (!defined($avg_length) || $avg_length <= 0)
	{
		$avg_length = 10;
	}

	my $length = int(rand($avg_length)) + 1;

	my @chars = ();
	for (my $var = 0; $var < $length; $var++)
	{
		my $index = int(rand(scalar @letter));
		push @chars, $letter[$index];
	}
	
	return join('', @chars);
}

