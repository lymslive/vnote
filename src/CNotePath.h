#ifndef CNOTEPATH_H__
#define CNOTEPATH_H__
// 日记虚拟目录树结点

#include "CNote.h"

class CNotePath
{
public:
	CNotePath();
	CNotePath(const string &sName, CNotePath *pParent = NULL);
	virtual ~CNotePath ();

	// 添加一个子目录，返回新建的指针或原有指针
	CNotePath *AddChild(const string &sName);
	// 添加多层子目录，容器中每个字符串是一个中间子目录
	CNotePath *AddChild(const vector<string> &vsPath);
	// 添加多层子目录，单字符串用/分隔多层次
	CNotePath *AddChildPath(const string &sName);

	// 获取指定子目录，不存在时返回空指针
	CNotePath *Child(const string &sName);
	CNotePath *Child(const vector<string> &vsPath);
	CNotePath *ChildPath(const string &sName);

	// 子目录列表信息
	int ChildCount() { return m_children.size(); }
	const map<string, CNotePath *> &Children() { return m_children; }

	// 向上查找父目录及至根结点，要结点的父目录为空
	CNotePath *Parent() { return m_parent; }
	CNotePath *Root();
	// 全路径名与去相对路径名(除根目录名)
	string FullName() const;
	string RelativeName() const;

	// 添加一个日记至该目录
	void AddNote(CNote *pNote);
	// 从该目录中删除一个日记
	void DelNote(CNote *pNote);
	const VPNOTE &Notes() { return m_notes; }

	// 清空目录树
	void Clear();

	// 将 sName 拆分路径（/分隔），添加到容器 vsPath 末尾
	// 返回添加的个数，即目录层次，至少有一层
	static int SplitPath(const string &sName, vector<string> &vsPath);

	// 目录名是否合法
	static bool ValidPathName(const string &sName);

	// 向下统计共有多少标签，如果传入 map ，则分别统计每个标签下的日记数量
	int CountTagDown();
	int CountTagDown(map<string, int> &vmTags);

	// 以 sRootdir 为根目录在文件系统中建立目录（有子标签时才视为目录）
	EINT MakeRealPath(const string &sRootdir);
	// 在文件系统中保存标签索引文件
	EINT SaveTagFile(const string &sRootdir);
	// 在文件系统中建立整个标签树（递归）
	EINT BuildTagTree(const string &sRootdir);

private:
	// 当前目录名
	string m_name;
	// 父目录
	CNotePath *m_parent;
	// 子目录列表
	map<string, CNotePath *> m_children;
	// 当前目录下的日记
	VPNOTE m_notes;

private:
	// 禁用拷贝与赋值
	CNotePath(const CNotePath &that);
	CNotePath &operator=(const CNotePath &that);
};

#endif /* end of include guard: CNOTEPATH_H__ */
