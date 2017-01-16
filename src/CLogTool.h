#ifndef CLOGTOOL_H__
#define CLOGTOOL_H__

#include <string>
using std::string;

class CLogTool
{
public:
	static CLogTool *Instance();
	static void SetLogFile(const string &sFileName);
	void FlushLog(const char *szFile, int iLineNo, const char *szFunction, const char *szMsg, ...);

private:
	string m_logFile;
	CLogTool(){ }
};

#define SOURCE_INOF __FILE__, __LINE__, __FUNCTION__
#define LOG(msg, arg...) do{CLogTool::Instance()->FlushLog(SOURCE_INOF, msg, ##arg);}while(0)

#endif /* end of include guard: CLOGTOOL_H__ */
