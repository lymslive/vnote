#ifndef COMMDEF_H__
#define COMMDEF_H__

// 使用标准库
#include <string>
#include <vector>
#include <set>
#include <map>
#include <iostream>

using std::string;
using std::vector;
using std::set;
using std::map;
using std::ostream;
using std::cout;
using std::cin;
using std::cerr;
using std::endl;

// 表示错误码的整数
typedef int EINT;
const EINT OK = 0;
const EINT NOK = -1;

#define PASS 1
#define break_if(expr) if(expr) break
#define continue_if(expr) if(expr) continue
#define return_if(expr, args...) do{if (expr){return args;}}while(0)

// 系统路径分隔符
const char PATH_SEP = '/';
const char CHAR_SPACE = ' ';
const char CHAR_TABLE = 0x9;

#endif /* end of include guard: COMMDEF_H__ */
