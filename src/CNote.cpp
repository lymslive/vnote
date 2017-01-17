#include "CNote.h"
#include "CNoteParser.h"
#include "CLogTool.h"
#include <sstream>
#include <numeric>

CNote::CNote(const string &sFileName, const string &sBasedir) :
	m_date(0),
	m_seqno(0),
	m_delete(false),
	m_bad(false),
	m_file(sFileName)
{
	CNoteParser jParser(sBasedir);
	ReadFile(sFileName, jParser);
}

CNote::CNote(const string &sFileName, const CNoteParser &jParser) :
	m_date(0),
	m_seqno(0),
	m_delete(false),
	m_bad(false),
	m_file(sFileName)
{
	ReadFile(sFileName, jParser);
}

void CNote::ReadFile(string sFileName, const CNoteParser &jParser)
{
	EINT iRet = jParser.ReadNote(sFileName, *this);
	if (iRet != OK)
	{
		LOG("fails to read note: %s", sFileName.c_str());
		m_bad = true;
	}
}

bool CNote::InTag(string sTag)
{
	if (sTag.empty())
	{
		return false;
	}

	auto it = m_tag.find(sTag);
	return it != m_tag.end();
}

void CNote::AddTag(string sTag)
{
	if (sTag.empty())
	{
		LOG("try to add empty tag?");
		return;
	}

	m_tag.insert(sTag);
}

bool CNote::RmTag(string sTag)
{
	auto ret = m_tag.erase(sTag);
	return ret > 0;
}

bool CNote::ReDate(DINT iDate)
{
	CPlainDate jDate(iDate);
	if (!jDate.IsValid())
	{
		LOG("invalid date: %d", iDate);
		return false;
	}

	m_date = iDate;
	return true;
}

void CNote::ReTitle(const string &sTitle)
{
	if (sTitle.empty())
	{
		LOG("try to retitle to empty string?");
		return;
	}

	m_title = sTitle;
}

bool CNote::MoveFile(string sNewFile)
{
	if (sNewFile.empty())
	{
		LOG("try to move file to empty path?");
		return false;
	}

	// todo:??
	// 实际移动文件系统中的文件
	m_file = sNewFile;

	return true;
}

string CNote::NoteID() const
{
	using std::ostringstream;

	ostringstream str;
	str << m_date << "_" << m_seqno;

	return str.str();
}

string CNote::Desc() const
{
	using std::ostringstream;
	using std::endl;

	ostringstream str;
	str << "File:  " << m_file << endl;
	str << "Title: " << m_title << endl;
	str << "Date:  " << m_date << endl;
	str << "Tags:  ";

	for (auto it = m_tag.begin(); it != m_tag.end(); ++it)
	{
		auto &item = *it;
		str << item << ", ";
	}
	str << endl;

	return str.str();
}

bool operator==(const CNote &lhs, const CNote &rhs)
{
	return lhs.m_date == rhs.m_date && lhs.m_seqno == rhs.m_seqno;
}

bool operator!=(const CNote &lhs, const CNote &rhs)
{
	return !(lhs == rhs);
}

bool operator<(const CNote &hls, const CNote &rhs)
{
	return (hls.m_date < rhs.m_date)
		|| (hls.m_date == rhs.m_date && hls.m_seqno < rhs.m_seqno);
}

ostream & operator<<(ostream &os, const CNote &rhs)
{
	os << rhs.Desc();
	return os;
}

#ifdef CNOTE_TEST

#include <iostream>
using std::cout;
using std::cerr;
using std::endl;
int main(int argc, char *argv[])
{
	if (argc < 2) // 程序本身算一个参数
	{
		cerr << "need a filename as argument" << endl;
		return -1;
	}

	// 命令行参数1为文件名
	string sFileName(argv[1]);

	CNote jNote(sFileName);
	cout << jNote << endl;

	return 0;
}
#endif
