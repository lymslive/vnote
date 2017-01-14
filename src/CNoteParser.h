#ifndef CNOTEPARSER_H__
#define CNOTEPARSER_H__
// 解析日记的功能类封装

#include <string>
#include "commdef.h"

using std::string;

class CNote;

class CNoteParser
{
public:
	CNoteParser();
	CNoteParser(const string &sBasedir);
	// virtual ~CNoteParser();

	EINT ReadNote(const string &sFileName, CNote &jNote) const;
private:
	// 需要保存一个基准目录，日记文件相对路径
	string m_basedir;

public:
	// 拆分文件名格式
	static EINT SplitFileName(const string &sFileName, CNote &jNote);

	// 移除文本行前导的空格与 # 符号，返回剩余部分的复制
	static string StripSharp(const string &sText);

	// 解析反引号元数据行，返回成功解析的个数
	static int ParseNoteMeta(const string &sLine, CNote &jNote);

	// 往对象 jNote 中插入元数据，返回元数据类型
	static int InsertNoteMete(const string &sMeta, CNote &jNote);

	// 三类元数据类型，日期，路径，标签
	enum ENoteMetaType { NOTE_META_ERROR, NOTE_META_DATE, NOTE_META_PATH, NOTE_META_TAG, };
};

#endif /* end of include guard: CNOTEPARSER_H__ */
