#ifndef CNOTEPARSER_H__
#define CNOTEPARSER_H__
// 解析日记的功能类封装

#include <string>
#include "commdef.h"
#include "CPlainDate.h"

class CNote;

class CNoteParser
{
	// 静态方法
public:
	// 读取日记文件，若成功，返回新建的日记
	static CNote *ReadNote(const string &sFileName);
	// 将日记读入已存在的日记对象中，文件名提供为全路径
	static EINT ReadNote(const string &sFileName, CNote &jNote);

	// 拆分文件名格式
	static EINT SplitFileName(const string &sFileName, CNote &jNote);
	// 过滤文件名，合适的文件名返回 true
	static bool FilterFileName(const string &sFileName);

	// 移除文本行前导的空格与 # 符号，返回剩余部分的复制
	static string StripSharp(const string &sText);

	// 解析反引号元数据行，返回成功解析的个数
	static int ParseNoteMeta(const string &sLine, CNote &jNote);

	// 往对象 jNote 中插入元数据，返回元数据类型
	static int InsertNoteMete(const string &sMeta, CNote &jNote);

	// 三类元数据类型，日期，路径，标签
	enum ENoteMetaType { NOTE_META_ERROR, NOTE_META_DATE, NOTE_META_PATH, NOTE_META_TAG, };

	// 缓存文件名解析结果
	struct SFileNamePart
	{
		string sFileName;
		bool bValid;
		DINT iDate;
		int iSeqno;
		bool bPrivatea;
		string sTitle;
	};
	static SFileNamePart m_sCache;

};

#endif /* end of include guard: CNOTEPARSER_H__ */
