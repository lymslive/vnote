#ifndef COMMDEF_H__
#define COMMDEF_H__

// 表示错误码的整数
typedef int EINT;
const EINT OK = 0;
const EINT NOK = -1;

#define break_if(expr) if(expr) break
#define continue_if(expr) if(expr) continue
#define return_if(expr, args...) do{if (expr){return args;}}while(0)

// 日志标签路径分隔符
const char PATH_SEP = '/';

// 日记文件名最小字符长度，前8个为日期
#define MIN_NOTE_FILENAME_LENGTH 10
#define HEAD_DATE_STRING_LENGTH 8
// 最多解析日记文件前几行的内容
#define MAX_NOTE_FILE_HEAD_LINE 10


#endif /* end of include guard: COMMDEF_H__ */
