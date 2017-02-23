#include "CNote.h"
#include "CNoteParser.h"
#include "CLogTool.h"
#include <sstream>
#include <numeric>
#include "CFileDir.h"
#include <stdlib.h>
#include <algorithm>

CNote::CNote(const string &sFileName, const string &sBasedir) :
	m_date(0),
	m_seqno(0),
	m_private(false),
	m_delete(false),
	m_bad(false),
	m_file(sFileName)
{
	if (sBasedir.empty())
	{
		ReadFile(sFileName);
	}
	else
	{
		ReadFile(sBasedir + PATH_SEP + sFileName);
	}
}

void CNote::ReadFile(string sFileName)
{
	EINT iRet = CNoteParser::ReadNote(sFileName, *this);
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

	std::transform(sTag.begin(), sTag.end(), sTag.begin(), tolower);
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

	std::transform(sTag.begin(), sTag.end(), sTag.begin(), tolower);
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

string CNote::NoteName() const
{
	string sName = NoteID();
	if (m_private)
	{
		sName.append("-");
	}

	return sName;
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

string CNote::ListLine(bool bTags) const
{
	string sLine = NoteName() + CHAR_TABLE + m_title;

	if (bTags)
	{
		for (auto it = m_tag.begin(); it != m_tag.end(); ++it)
		{
			sLine += CHAR_TABLE + *it;
		}
	}

	return sLine;
}

EINT CNote::ReadCache(string sLine)
{
	// 日期
	string::size_type iPos = sLine.find('_');
	if (iPos == string::npos)
	{
		LOG("Invalid note cache entry line: %s", sLine.c_str());
		return NOK;
	}

	string sDate = sLine.substr(0, iPos);
	m_date = atoi(sDate.c_str());
	if (m_date <= 0)
	{
		LOG("Invalid note cache entry line: %s", sLine.c_str());
		return NOK;
	}

	// 序号
	string::size_type iNextPos = sLine.find(CHAR_TABLE, ++iPos);
	if (iNextPos == string::npos)
	{
		LOG("Invalid note cache entry line: %s", sLine.c_str());
		return NOK;
	}

	string sTmp = sLine.substr(iPos, iNextPos - iPos);
	m_seqno = atoi(sTmp.c_str());
	if (m_seqno <= 0)
	{
		LOG("Invalid note cache entry line: %s", sLine.c_str());
		return NOK;
	}

	// 标题
	iPos = iNextPos + 1;
	iNextPos = sLine.find(CHAR_TABLE, iPos);
	if (iNextPos == string::npos)
	{
		sTmp = sLine.substr(iPos);
	}
	else
	{
		sTmp = sLine.substr(iPos, iNextPos - iPos);
	}
	m_title = sTmp;

	// 剩余的都是标签
	if (iNextPos == string::npos)
	{
		return OK;
	}

	iPos = iNextPos + 1;
	while (iNextPos != string::npos)
	{
		iNextPos = sLine.find(CHAR_TABLE, iPos);
		if (iNextPos == string::npos)
		{
			sTmp = sLine.substr(iPos);
		}
		else
		{
			sTmp = sLine.substr(iPos, iNextPos - iPos);
			iPos = iNextPos + 1;
		}
		m_tag.insert(sTmp);
	}

	// 文件名
	m_file = string(NOTE_DATE_DIR) + PATH_SEP + NoteID() + NOTE_FILE_SUFFIX;

	return OK;
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
