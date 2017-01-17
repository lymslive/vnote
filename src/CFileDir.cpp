#include "CFileDir.h"
#include <dirent.h>
#include "CLogTool.h"
#include <string.h>
#include "commdef.h"

CFileDir::CFileDir(const string &sName, CFileDir *pParent) :
	// m_name(sName),
	m_parent(pParent),
	m_subRead(false)
{
	if (sName.empty())
	{
		LOG("try to create CFileDir object from empty name?");
		return;
	}

	// 去除目录名尾部可能的 /
	int iEndPos = sName.size() - 1;
	if (sName[iEndPos] == PATH_SEP && sName.size() > 1)
	{
		m_name = sName.substr(0, iEndPos);
	}
	else
	{
		m_name = sName;
	}

	ReadCurDir();
}

CFileDir::~CFileDir()
{
	for (auto it = m_children.begin(); it != m_children.end(); ++it)
	{
		CFileDir *pChild = it->second;
		if (pChild)
		{
			delete pChild;
			it->second = NULL;
		}
	}
}

int CFileDir::ReadCurDir()
{
	if (m_name.empty())
	{
		LOG("try to read empty named dir?");
		return 0;
	}

	DIR *pDir = NULL;
	struct dirent *pEntry = NULL;

	string sFullName = FullName();
	if ((pDir = opendir(sFullName.c_str())) == NULL)
	{
		LOG("cannot open dir: %s", m_name.c_str());
		return 0;
	}

	int iRead = 0;
	while ((pEntry = readdir(pDir)) != NULL)
	{
		if (strcmp(pEntry->d_name, ".") == 0 || strcmp(pEntry->d_name, "..") == 0)
		{
			continue;
		}

		++iRead;
		string sName(pEntry->d_name);

		if (pEntry->d_type == DT_DIR)
		{
			m_children[sName] = NULL;
		}
		else
		{
			m_files.insert(sName);
		}
	}

	return iRead;
}

int CFileDir::ReadSubDir()
{
	if (m_subRead)
	{
		LOG("have already read subdir: %s", m_name.c_str());
		return 0;
	}

	int iRead = 0;
	for (auto it = m_children.begin(); it != m_children.end(); ++it)
	{
		string sName = it->first;
		if (sName.empty())
		{
			LOG("this dir[%s] have empty subdir?", m_name.c_str());
			continue;
		}

		if (it->second)
		{
			LOG("have already read subdir: %s/%s", m_name.c_str(), sName.c_str());
			continue;
		}

		CFileDir *pChild = new CFileDir(sName, this);
		if (!pChild)
		{
			LOG("fails to allocat space for subdir of: %s", m_name.c_str());
			break;
		}

		it->second = pChild;
		++iRead;
	}

	m_subRead = true;
	return iRead;
}

CFileDir * CFileDir::RootDir()
{
	CFileDir *pParent = this;
	while (pParent->m_parent)
	{
		pParent = pParent->m_parent;
	}
	return pParent;
}

string CFileDir::FullName() const
{
	vector<string> vsPath;
	vsPath.push_back(m_name);

	// 上溯取得各父目录名
	const CFileDir *pParent = this;
	while (pParent->m_parent)
	{
		pParent = pParent->m_parent;
		vsPath.push_back(pParent->m_name);
	}

	// 反向接接全路径
	int iPos = vsPath.size();
	string sFullName = vsPath[--iPos];
	while (--iPos >= 0)
	{
		sFullName += PATH_SEP;
		sFullName += vsPath[iPos];
	}

	return sFullName;
}

void CFileDir::GetAllFiles(vector<string> &vsFileList, int iDepth)
{
	// 本目录的文件
	string sFullPath = FullName();
	sFullPath += PATH_SEP;

	for (auto it = m_files.begin(); it != m_files.end(); ++it)
	{
		vsFileList.push_back(sFullPath + *it);
	}

	// 深度控制
	--iDepth;
	if (iDepth == 0)
	{
		return;
	}

	if (!m_subRead)
	{
		ReadSubDir();
	}

	// 子目录的文件
	for (auto it = m_children.begin(); it != m_children.end(); ++it)
	{
		CFileDir *pChild = it->second;
		ASSERT_RET(pChild);

		pChild->GetAllFiles(vsFileList, iDepth);
	}
}

/*********** 单元测试 ***********/

#ifdef CFILEDIR_TEST
#include <iostream>
#include "stdlib.h"

using std::cout;
using std::cerr;
using std::endl;

int main(int argc, char *argv[])
{
	if (argc < 2)
	{
		cerr << "command line argument: basedir depth" << endl;
		return -1;
	}

	// 命令行参数1为文件名
	string sDirName(argv[1]);

	int iDepth = 0;
	if (argc >= 3)
	{
		iDepth = atoi(argv[2]);
	}

	// 读取目录下所有文件
	CFileDir jDir(sDirName);
	vector<string> vsFileList;
	jDir.GetAllFiles(vsFileList, iDepth);

	for (auto it = vsFileList.begin(); it != vsFileList.end(); ++it)
	{
		cout << *it << endl;
	}

	return 0;
}
#endif
