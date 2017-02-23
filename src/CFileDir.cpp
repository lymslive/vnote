#include "CFileDir.h"
#include <dirent.h>
#include "CLogTool.h"
#include <string.h>

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
	m_name = TrimTailSlash(sName);

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

string CFileDir::RelativeName() const
{
	if (!m_parent)
	{
		// 已经是根目录，返回空字符串
		return string();
	}

	vector<string> vsPath;

	// 上溯取得各父目录名
	const CFileDir *pParent = this;
	while (pParent->m_parent)
	{
		vsPath.push_back(pParent->m_name);
		pParent = pParent->m_parent;
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

void CFileDir::GetAllFiles(vector<string> &vsFileList, int iDepth, const char *pSuffix)
{
	// 本目录的文件
	string sFullPath = RelativeName();
	if (!sFullPath.empty())
	{
		sFullPath += PATH_SEP;
	}

	for (auto it = m_files.begin(); it != m_files.end(); ++it)
	{
		if (!pSuffix)
		{
			if ((*it).find(pSuffix) == string::npos)
			{
				continue;
			}
		}
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

		pChild->GetAllFiles(vsFileList, iDepth, pSuffix);
	}
}

string CFileDir::GetDirPart(const string &sFileName)
{
	string sBasedir;

	// 取文件目录部分，最后一个 / 之前部分
	string::size_type iPos = sFileName.rfind(PATH_SEP);
	if (iPos != string::npos)
	{
		if (iPos == PATH_SEP) // 就是系统根目录(/)
		{
			sBasedir = PATH_SEP;
		}
		else
		{
			sBasedir = sFileName.substr(0, iPos);
		}
	}
	else
	{
		sBasedir = '.'; // 当前目录
	}

	return sBasedir;
}

string CFileDir::GetFilePart(const string &sFileName)
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

	return sLastName;
}

string CFileDir::TrimTailSlash(const string &sFileName)
{
	string sCleanName;

	int iEndPos = sFileName.size() - 1;
	if (sFileName[iEndPos] == PATH_SEP && sFileName.size() > 1)
	{
		sCleanName = sFileName.substr(0, iEndPos);
	}
	else
	{
		sCleanName = sFileName;
	}

	return sCleanName;
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
