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

// 单例宏
#define ICLOGTOOL CLogTool::Instance()

// 日志宏
#define SOURCE_INOF __FILE__, __LINE__, __FUNCTION__
// 一般错误日志宏
#define LOG(msg, args...) do{ICLOGTOOL->FlushLog(SOURCE_INOF, msg, ##args);}while(0)

// 冗余调试宏
#ifndef NDEBUG
#define DLOG(msg, args...) do{ICLOGTOOL->FlushLog(SOURCE_INOF, msg, ##args);}while(0)
#else
#define PASS 1
#define DLOG(msg, args...) PASS
#endif

#define ASSERT_RET(expr, arg...) do{if (!(expr)){ LOG("assert \"%s\" failed", #expr); return arg;}}while(0)
#define ASSERT(expr) do{if (!(expr)){ LOG("assert \"%s\" failed", #expr);}}while(0)

#endif /* end of include guard: CLOGTOOL_H__ */
