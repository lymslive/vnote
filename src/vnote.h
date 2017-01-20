#ifndef VNOTE_H__
#define VNOTE_H__

// 日记系统设定参数

// 日记文件名最小字符长度，前8个为日期
#define MIN_NOTE_FILENAME_LENGTH 10
#define HEAD_DATE_STRING_LENGTH 8
// 最多解析日记文件前几行的内容
#define MAX_NOTE_FILE_HEAD_LINE 10

// 标题前缀
const char PREFIX_TITLE = '#';
// 标签前缀
const char PREFIX_TAG = '/';

#endif /* end of include guard: VNOTE_H__ */
