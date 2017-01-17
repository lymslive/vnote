#ifndef CFILEDIR_H__
#define CFILEDIR_H__
// 文件目录类封装

#include <string>
#include <vector>
#include <set>
#include <map>

using std::string;
using std::vector;
using std::set;
using std::map;

class CFileDir
{
public:
	CFileDir(const string &sName, CFileDir *pParent = NULL);
	~CFileDir();

	// 读入本目录内容，返回读入的条目数
	int ReadCurDir();
	// 打开子目录，向下扩展一层树，返回已处理的子目录数
	int ReadSubDir();

	// 成员获取函数
	string Name() const { return m_name; }
	CFileDir *Parent() const { return m_parent; }
	map<string, CFileDir *> &Children() { return m_children; };
	set<string> &Files() { return m_files; }

	// 最上层根目录（无父目录）
	CFileDir *RootDir();
	// 全路径名
	string FullName() const;

	// 递归展开所有文件名（相对本目录），存入 vsFileList 之后
	// 可指定目录深度，默认 0 不限，1 表示只含当前目录
	// 只含普通文件名，不包括目录名
	void GetAllFiles(vector<string> &vsFileList, int iDepth = 0);
private:
	// 当前目录名
	string m_name;
	// 父目录
	CFileDir *m_parent;
	// 子目录列表
	map<string, CFileDir *> m_children;
	// 该目录下的普通文件
	set<string> m_files;

	// 已读取子目录标记位
	bool m_subRead;
};

#endif /* end of include guard: CFILEDIR_H__ */
