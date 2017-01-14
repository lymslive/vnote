#include "CNote.h"
#include "CNoteParser.h"
#include <sstream>
#include <numeric>

CNote::CNote(const string &sFileName, const string &sBasedir) : m_date(0), m_seqno(0), m_delete(false)
{
	CNoteParser jParser(sBasedir);
	ReadFile(sFileName, jParser);
}

CNote::CNote(const string &sFileName, const CNoteParser &jParser) : m_date(0), m_seqno(0), m_delete(false)
{
	ReadFile(sFileName, jParser);
}

void CNote::ReadFile(string sFileName, const CNoteParser &jParser)
{
	EINT iRet = jParser.ReadNote(sFileName, *this);
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
		return false;
	}

	m_date = iDate;
	return true;
}

void CNote::ReTitle(const string &sTitle)
{
	if (sTitle.empty())
	{
		return;
	}

	m_title = sTitle;
}

bool CNote::MoveFile(string sNewFile)
{
	if (sNewFile.empty())
	{
		return false;
	}

	// todo:??
	// 实际移动文件系统中的文件
	m_file = sNewFile;

	return true;
}

string CNote::Desc() const
{
	using std::ostringstream;
	using std::endl;

	ostringstream str;
	str << m_title << endl;

	for (auto it = m_tag.begin(); it != m_tag.end(); ++it)
	{
		auto &item = *it;
		str << item << ", ";
	}
	str << endl;

	str << m_file;

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
