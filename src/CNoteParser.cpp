#include "CNoteParser.h"
#include "CNote.h"
#include "CLogTool.h"
#include <stdlib.h>
#include <fstream>
#include "CFileDir.h"
#include "vnote.h"

// 静态类成员初始化
CNoteParser::SFileNamePart CNoteParser::m_sCache;

CNote* CNoteParser::ReadNote(const string &sFileName)
{
	if (!FilterFileName(sFileName))
	{
		return NULL;
	}

	CNote *pNote = new CNote(sFileName);
	if (!pNote)
	{
		LOG("fails to allocate space for CNote");
		return NULL;
	}

	return pNote;
}

EINT CNoteParser::ReadNote(const string &sFileName, CNote &jNote)
{
	// 拆分文件名
	EINT iRet = SplitFileName(sFileName, jNote);
	if (iRet != OK)
	{
		LOG("fails to parse not file name: %s", sFileName.c_str());
		return iRet;
	}

	// 打开文件
	using std::ifstream;
	ifstream fin(sFileName);
	if (!fin)
	{
		LOG("fails to open note file:%s", sFileName.c_str());
		return NOK;
	}

	// 读取每一行
	string sLine;
	int iLineNo = 0;
	// 日记元数据行标记
	bool bMetaStart = false;
	bool bMetaStop = false;

	while (std::getline(fin, sLine))
	{
		iLineNo ++;
		// 第一行是标题
		if (iLineNo == 1)
		{
			string sTitle = StripSharp(sLine);
			if (sTitle.empty())
			{
				LOG("unexpeted occur empty note title?");
				iRet = NOK;
				break;
			}
			jNote.m_title = sTitle;
			continue;
		}

		// 略过空行
		continue_if(sLine.empty());

		// 解析元数据行，反引号开始的行
		if (sLine[0] == '`')
		{
			if (!bMetaStart)
			{
				bMetaStart = true;
			}
			if (bMetaStart && !bMetaStop)
			{
				ParseNoteMeta(sLine, jNote);
			}
		}
		else
		{
			if (bMetaStart)
			{
				bMetaStop = true;
			}
		}

		// 元数据全部读完
		break_if(bMetaStop);

		// 最大行数
		break_if(iLineNo > MAX_NOTE_FILE_HEAD_LINE);
	}

	fin.close();
	return iRet;
}

EINT CNoteParser::SplitFileName(const string &sFileName, CNote &jNote)
{
	string sLastName = CFileDir::GetFilePart(sFileName);
	if (sLastName.compare(m_sCache.sFileName) != 0)
	{
		FilterFileName(sFileName);
	}

	if (!m_sCache.bValid)
	{
		DLOG("invalid note filename: %s", sFileName.c_str());
		return NOK;
	}
	else
	{
		jNote.m_date = m_sCache.iDate;
		jNote.m_seqno = m_sCache.iSeqno;
		jNote.m_private = m_sCache.bPrivatea;
		jNote.m_title = m_sCache.sTitle;
	}

	return OK;
}

bool CNoteParser::FilterFileName(const string &sFileName)
{
	string sLastName = CFileDir::GetFilePart(sFileName);

	if (sLastName.compare(m_sCache.sFileName) == 0)
	{
		return m_sCache.bValid;
	}

	m_sCache.sFileName = sLastName;
	m_sCache.bValid = false;

	if (sLastName.size() < MIN_NOTE_FILENAME_LENGTH)
	{
		DLOG("note filename too short: %s", sLastName.c_str());
		return false;
	}

	// 第一部分是 yyyymmdd 8 位数
	string sDate = sLastName.substr(0, HEAD_DATE_STRING_LENGTH);
	m_sCache.iDate = atoi(sDate.c_str());
	if (m_sCache.iDate <= 0)
	{
		DLOG("fails to parse date from filename: %s", sLastName.c_str());
		return false;
	}

	// 第二部分是当天日记序号
	string sLeft = sLastName.substr(HEAD_DATE_STRING_LENGTH + 1);
	m_sCache.iSeqno = atoi(sLeft.c_str());
	if (m_sCache.iSeqno <= 0)
	{
		DLOG("fails to parse seqno from filename: %s", sLastName.c_str());
		return false;
	}

	// 第三部分是日记标题，第二个下划线之后部分
	string::size_type iPos = sLastName.find('_', HEAD_DATE_STRING_LENGTH + 1);
	if (iPos != string::npos && ++iPos != sLastName.size())
	{
		m_sCache.sTitle = sLastName.substr(iPos);
	}

	// 是否有私有标记
	iPos = sLastName.find("-.", HEAD_DATE_STRING_LENGTH + 1);
	if (iPos != string::npos)
	{
		m_sCache.bPrivatea = true;
	}
	else
	{
		m_sCache.bPrivatea = false;
	}

	m_sCache.bValid = true;
	return true;
}

string CNoteParser::StripSharp(const string &sText)
{
	string sTitle;

	string::size_type iPos = sText.find_first_not_of(" #");
	if (iPos != string::npos)
	{
		sTitle = sText.substr(iPos);
	}
	else
	{
		sTitle = sText;
	}

	return sTitle;
}

// 反引号元数据允许三类，`数字日期`，`/路径以斜杠开始`，`标签`
int CNoteParser::ParseNoteMeta(const string &sLine, CNote &jNote)
{
	int iRead = 0;
	char cQuote = '`';
	
	// 反引用起止位置，一行可多个
	string::size_type iStartPos = 0;
	string::size_type iStopPos = 0;

	iStartPos = sLine.find(cQuote, 0);
	while (iStartPos != string::npos)
	{
		if (++iStartPos == sLine.size()) // 已经是最后一个字符
		{
			break;
		}

		iStopPos = sLine.find(cQuote, iStartPos);
		if (iStopPos == string::npos || iStopPos - iStartPos <= 0)
		{
			break;
		}

		// 提取引号中间部分
		string sMeta = sLine.substr(iStartPos, iStopPos - iStartPos);
		int iType = InsertNoteMete(sMeta, jNote);
		if (iType != NOTE_META_ERROR)
		{
			++iRead;
		}

		// 继续查找下一个元数据
		iStartPos = sLine.find(cQuote, iStopPos + 1);
	}

	return iRead;
}

int CNoteParser::InsertNoteMete(const string &sMeta, CNote &jNote)
{
	if (sMeta.empty())
	{
		LOG("try to insert empty tag?");
		return NOTE_META_ERROR;
	}

	// 能转为数字，认为是表示日期
	int iTryDate = atoi(sMeta.c_str());
	if (iTryDate > 0)
	{
		jNote.m_date = iTryDate;
		return NOTE_META_DATE;
	}

	// 其余表示标签
	jNote.AddTag(sMeta);

	// 包含斜线，可表示路径
	if (sMeta.find(PATH_SEP) != string::npos)
	{
		return NOTE_META_PATH;
	}
	else
	{
		return NOTE_META_TAG;
	}
}
