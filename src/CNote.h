#ifndef CNOTE_H__
#define CNOTE_H__

#include "CPlainDate.h"
#include "commdef.h"
#include "vnote.h"

class CNoteParser;

class CNote
{
	friend bool operator==(const CNote &lhs, const CNote &rhs);
	friend bool operator!=(const CNote &lhs, const CNote &rhs);
	friend bool operator<(const CNote &lhs, const CNote &rhs);
	friend ostream & operator<<(ostream &os, const CNote &rhs);

	friend class CNoteParser;

public:
	CNote() : m_date(0), m_seqno(0), m_delete(false) { }
	CNote(const string &sFileName, const string &sBasedir = "");
	virtual ~CNote(){ };

	// 从文件中读入日记
	void ReadFile(string sFileName);

	// 读取成员数据
	string Title() { return m_title; }
	DINT Date() { return m_date; }
	string File() { return m_file; }
	const set<string> Tag() const { return m_tag; }

	// 该日志是否归属某标签下
	bool InTag(string sTag);
	void AddTag(string sTag);
	bool RmTag(string sTag);

	// 修改日期
	bool ReDate(DINT iDate);
	// 更改日记标题
	void ReTitle(const string &sTitle);
	// 移动日记文件
	bool MoveFile(string sNewFile);

	void MarkDelete() { m_delete = true; }
	bool IsDeleted() { return m_delete; }
	bool IsBad() { return m_bad; }

	// 转换为一个描叙该日记对象的字符串
	string Desc() const;
	// 日期与序号联接，可作为日记ID
	string NoteID() const;
	// 日记文件名，日期序号私有标记，不再有标题
	string NoteName() const;
	// 生成简明的列表行字符串：文件名 + 制表 + 标题
	// 若 bTags ，则将所有标签列在其后，也用制表分隔
	string ListLine(bool bTags = false) const;

	// 从 cache 数据库中的一行完成 Note 对象
	EINT ReadCache(string sLine);

private:
	// 日记文件名格式：yyyymmdd_n_日记标题
	DINT m_date;
	int m_seqno;
	bool m_private;
	string m_title;
	// 日记可归属于多个目录及标签
	set<string> m_tag;
	string m_summary;
	// 实际文件系统的文件名
	string m_file;

	// 标记已删除
	bool m_delete;
	// 不正确的日记
	bool m_bad;
};

// 运算符重载支持
bool operator==(const CNote &lhs, const CNote &rhs);
bool operator!=(const CNote &lhs, const CNote &rhs);
bool operator<(const CNote &lhs, const CNote &rhs);
ostream & operator<<(ostream &os, const CNote &rhs);

// 重定义指针的小于
class CNoteCompare
{
public:
	bool operator() (CNote* const& lhs, CNote* const& rhs) { return *lhs < *rhs; }
	bool operator() (const CNote &lhs, const CNote &rhs) { return lhs < rhs; }
};

// 收集日记指针的容器
typedef set<CNote *, CNoteCompare> VPNOTE;

#endif /* end of include guard: CNOTE_H__ */
