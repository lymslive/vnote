#include "CNoteParser.h"
#include "CNote.h"
#include "CLogTool.h"
#include <stdlib.h>
#include <fstream>

CNoteParser::CNoteParser()
{
}

CNoteParser::CNoteParser(const string &sBasedir) : m_basedir(sBasedir)
{
}

EINT CNoteParser::ReadNote(const string &sFileName, CNote &jNote) const
{
	// 拆分文件名
	EINT iRet = SplitFileName(sFileName, jNote);
	if (iRet != OK)
	{
		LOG("fails to parse not file name: %s", sFileName.c_str());
		return iRet;
	}

	// 获取完整路径名
	string sFullName;
	if (sFileName[0] != '/' & !m_basedir.empty())
	{
		sFullName = m_basedir + '/' + sFileName;
	}
	else
	{
		sFullName = sFileName;
	}

	// 打开文件
	using std::ifstream;
	ifstream in(sFullName);
	if (!in)
	{
		LOG("fails to open note file:%s", sFullName.c_str());
		return NOK;
	}

	// 读取每一行
	string sLine;
	int iLineNo = 0;
	// 日记元数据行标记
	bool bMetaStart = false;
	bool bMetaStop = false;

	while (std::getline(in, sLine))
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

	in.close();
	return iRet;
}

EINT CNoteParser::SplitFileName(const string &sFileName, CNote &jNote)
{
	string sLastName;

	// 取文件全路径名最后一部分，最后一个 / 之后部分
	string::size_type iPos = sFileName.rfind('/');
	if (iPos != string::npos && ++iPos != sFileName.size())
	{
		sLastName = sFileName.substr(iPos);
	}
	else
	{
		sLastName = sFileName;
	}

	if (sLastName.size() < MIN_NOTE_FILENAME_LENGTH)
	{
		LOG("note filename too short: %s", sFileName.c_str());
		return NOK;
	}

	// 第一部分是 yyyymmdd 8 位数
	string sDate = sLastName.substr(0, HEAD_DATE_STRING_LENGTH);
	jNote.m_date = atoi(sDate.c_str());
	if (jNote.m_date <= 0)
	{
		LOG("fails to parse date from filename: %s", sFileName.c_str());
		return NOK;
	}

	// 第二部分是当天日记序号
	string sLeft = sLastName.substr(HEAD_DATE_STRING_LENGTH + 1);
	jNote.m_seqno = atoi(sLeft.c_str());
	if (jNote.m_seqno <= 0)
	{
		LOG("fails to parse seqno from filename: %s", sFileName.c_str());
		return NOK;
	}

	// 第三部分是日记标题，第二个下划线之后部分
	iPos = sLastName.find('_', HEAD_DATE_STRING_LENGTH + 1);
	if (iPos != string::npos && ++iPos != sLastName.size())
	{
		jNote.m_title = sLastName.substr(iPos);
	}

	return OK;
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
