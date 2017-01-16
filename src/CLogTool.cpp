#include "CLogTool.h"
#include <stdio.h>
#include <stdarg.h>

CLogTool * CLogTool::Instance()
{
	static CLogTool s_jLogTool;
	return &s_jLogTool;
}

void CLogTool::SetLogFile(const string &sFileName)
{
	Instance()->m_logFile = sFileName;
}

void CLogTool::FlushLog(const char *szFile, int iLineNo, const char *szFunction, const char *szMsg, ...)
{
	// 打开日志
	FILE *pLog = NULL;
	if (!m_logFile.empty())
	{
		pLog = fopen(m_logFile.c_str(), "a");
		if (!pLog)
		{
			fprintf(stderr, "can not opne log file: %s", m_logFile.c_str());
			return;
		}
	}

	// 日志前缀
	if (pLog)
	{
		fprintf(pLog, "[LOG][%s:%d (%s)] ", szFile, iLineNo, szFunction);
	}
	else
	{
		fprintf(stderr, "[LOG][%s:%d (%s)] ", szFile, iLineNo, szFunction);
	}

	// 可变参数的打印日志
	va_list pArg;
	va_start(pArg, szMsg);
	if (pLog)
	{
		vfprintf(pLog, szMsg, pArg);
		fprintf(pLog, "\n");
	}
	else
	{
		vfprintf(stderr, szMsg, pArg);
		fprintf(stderr, "\n");
	}
	va_end(pArg);

	// 关闭日志
	if (pLog)
	{
		fclose(pLog);
	}
}

