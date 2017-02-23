// 文件目录类封装
#ifndef CFILEDIR_H__
#define CFILEDIR_H__
#include "commdef.h"

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
	// 相对路径名，全路径名去除根目录名
	string RelativeName() const;

	// 递归展开所有文件名（包含），存入 vsFileList 之后
	// 可指定目录深度，默认 0 不限，1 表示只含当前目录
	// 只含普通文件名，不包括目录名，可指定 pSuffix 后缀名
	// 宜由根目录对象调用，输出文件名为相对根目录的相对路径名
	void GetAllFiles(vector<string> &vsFileList, int iDepth = 0, const char *pSuffix = NULL);
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

private:
	// 禁用拷贝与赋值
	CFileDir(const CFileDir &that);
	CFileDir &operator=(const CFileDir &that);

public:
	// 分隔路径中的目录部分与文件名部分
	static string GetDirPart(const string &sFileName);
	static string GetFilePart(const string &sFileName);
	// 去除目录名尾部可能的 /
	static string TrimTailSlash(const string &sFileName);
};

#endif /* end of include guard: CFILEDIR_H__ */
