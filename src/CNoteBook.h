#ifndef CNOTEBOOK_H__
#define CNOTEBOOK_H__
// 日记本类

#include "CNote.h"
#include "CPlainDate.h"
#include "commdef.h"

class CNoteParser;
class CNotePath;

class CNoteBook
{
public:
	CNoteBook();
	CNoteBook(const string &sBasedir);
	~CNoteBook();

private:
	// 日记本所在的根目录
	string m_basedir;

	// 所有日记数组，容器中存放指针
	VPNOTE m_vpNote;

	// 日期索引
	map<DINT, VPNOTE> m_dateIndex;
	// 虚拟目录层次
	CNotePath *m_rootPath;

	// 标记是否已读入日记本
	bool m_ready;

public:
	// 从根目录中搜索导入所有日志
	EINT ImportFromDir(const string &sBasedir, bool bUseCache = false);
	// 从缓存数据库中导入日志
	EINT ImportFromCache(const string &sCacheFile);

	// 从一份文件列表中导入日志，其内的文件名相对于它本身的目录
	EINT ImportFromFileList(const string &sFileList);

	// 建立索引与目录树，参数表示是否强制重建
	void BuildDateIndex(bool bRebuild = false);
	void BuildPathTree(bool bRebuild = false);

	// 将标签树输出至文件系统
	EINT OutputTagTree();
	// 输出整个日记本缓存
	EINT OutputCache();

	// 根据索引获取一组日记指针
	const VPNOTE *DateIndex(DINT iDate);
	const VPNOTE *TagIndex(const string &sTag) const;

	// 返回日记列表
	const VPNOTE &GetNotes() const { return m_vpNote; }
	const map<DINT, VPNOTE> &GetDateMap() const { return m_dateIndex; }

	// 增加一个新日记，返回日记指针
	CNote *AddNewNote();
	// 删除一个日记
	bool RemoveNote(CNote *pNote);

	// 修改某个日记信息，同步维护索引
	void AddNoteTag(CNote *pNote, string sTag);
	void DelNoteTag(CNote *pNote, string sTag);
	void ChangeNoteDate(CNote *pNote, DINT iDate);
	void ChangeNoteTitle(CNote *pNote, const string &sTitle);

	// 修改标签
	void ChangeBookTag(const string &sOldTag, const string &sNewTag);

	bool IsReady() { return m_ready; }

	string Desc() const;
private:
	// 禁用拷贝与赋值
	CNoteBook(const CNoteBook &that);
	CNoteBook &operator=(const CNoteBook &that);

	// 创建日记本，参数为文件名列表，相对m_basedir
	EINT CreateNoteBook(const vector<string> &vsFileList);
};

#endif /* end of include guard: CNOTEBOOK_H__ */
