// 日记查询类
#ifndef CNOTEQUERY_H__
#define CNOTEQUERY_H__

#include "commdef.h"
#include "CPlainDate.h"
#include "CNote.h"

class CNoteBook;
class CNoteQuery
{
public:
	CNoteQuery(CNoteBook *pNoteBook = NULL) : m_pCurBook(pNoteBook) { }
	// 外引一个有效的日记本指针，不负责释放
	virtual ~CNoteQuery() { };

	// 设定当前查询日记本，返回是否成功赋值
	bool SetBook(CNoteBook *pNoteBook);

	// 搜索限定结构体
	struct SQueryFace{
		string sText;  // 标签或标题
		DINT dBegin;   // 起始日期
		DINT dEnd;     // 结束日期
		SQueryFace() : dBegin(0), dEnd(0) { }
	};

	// 查询日记，返回结果集个数
	int Query(const vector<string> &vsInput);
	int Query(SQueryFace &stFace);
	// 可根据字符串格式决定查标题或标签，否则先尝试标签，然后标题
	int Query(const string &sText, DINT dBegin = 0, DINT dEnd = 0);
	// 返回上次结果集，每次查询前会重置
	const VPNOTE &LastResult() const { return m_vpResult; }

	int QueryTag(const string &sTag, DINT dBegin = 0, DINT dEnd = 0);
	int QueryTitle(const string &sTitle, DINT dBegin = 0, DINT dEnd = 0);
	int QueryDate(DINT dBegin, DINT dEnd = 0);

private:
	// 从文本搜索中再过滤日期条件，加入最终结果中
	int FilterDate(const VPNOTE *pTagNotes, DINT dBegin, DINT dEnd);

private:
	// 当前日记本
	CNoteBook *m_pCurBook;

	// 缓存上次查询结果
	VPNOTE m_vpResult;
};

#endif /* end of include guard: CNOTEQUERY_H__ */
