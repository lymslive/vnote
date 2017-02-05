#include <sys/stat.h>
#include "CNotePath.h"
#include "commdef.h"
#include "CLogTool.h"
#include "vnote.h"
#include <fstream>
#include <unistd.h>

CNotePath::CNotePath()
{
}

CNotePath::CNotePath(const string &sName, CNotePath *pParent) : m_name(sName), m_parent(pParent)
{
}

CNotePath::~CNotePath()
{
	// 析构函数，只需负责删除直接子目录结点，自动递归析构
	for (auto it = m_children.begin(); it != m_children.end(); ++it)
	{
		CNotePath *pItem = it->second;
		if (pItem)
		{
			delete pItem;
			it->second = NULL;
		}
	}
}

void CNotePath::Clear()
{
	this->~CNotePath();
	m_children.clear();
	m_notes.clear();
	m_parent = NULL;
	m_name.clear();
}

CNotePath * CNotePath::AddChild(const string &sName)
{
	if (!ValidPathName(sName))
	{
		LOG("invalid tag name: %s", sName.c_str());
		return NULL;
	}

	// 已有该子目录
	if (m_children.count(sName) > 0)
	{
		return m_children[sName];
	}

	// 新建子目录
	CNotePath *pChild = new CNotePath(sName, this);
	m_children[sName] = pChild;

	return pChild;
}

CNotePath * CNotePath::AddChild(const vector<string> &vsPath)
{
	if (vsPath.empty())
	{
		LOG("try to add empty tag path?");
		return NULL;
	}

	// 链式向下添加子目录
	CNotePath *pChild = this;
	for (auto it = vsPath.begin(); it != vsPath.end(); ++it)
	{
		pChild = pChild->AddChild(*it);
		if (!pChild)
		{
			break;
		}
	}

	return pChild;
}

CNotePath * CNotePath::AddChildPath(const string &sName)
{
	vector<string> vsPath;
	SplitPath(sName, vsPath);
	return AddChild(vsPath);
}

CNotePath * CNotePath::Child(const string &sName)
{
	if (!ValidPathName(sName))
	{
		LOG("invalid tag name: %s", sName.c_str());
		return NULL;
	}

	if (m_children.count(sName) > 0)
	{
		return m_children[sName];
	}
	else
	{
		return NULL;
	}
}

CNotePath * CNotePath::Child(const vector<string> &vsPath)
{
	if (vsPath.empty())
	{
		LOG("try to query empty tag path?");
		return NULL;
	}

	CNotePath *pChild = this;
	for (auto it = vsPath.begin(); it != vsPath.end(); ++it)
	{
		pChild = pChild->Child(*it);
		if (!pChild)
		{
			break;
		}
	}

	return pChild;
}

CNotePath * CNotePath::ChildPath(const string &sName)
{
	vector<string> vsPath;
	SplitPath(sName, vsPath);
	return Child(vsPath);
}

CNotePath * CNotePath::Root()
{
	CNotePath *pParent = this;
	while (pParent->m_parent)
	{
		pParent = pParent->m_parent;
	}
	return pParent;
}

string CNotePath::FullName() const
{
	vector<string> vsPath;
	vsPath.push_back(m_name);

	// 上溯取得各父目录名
	const CNotePath *pParent = this;
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

string CNotePath::RelativeName() const
{
	if (!m_parent)
	{
		// 已经是根目录，返回空字符串
		return string();
	}

	vector<string> vsPath;

	// 上溯取得各父目录名
	const CNotePath *pParent = this;
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

void CNotePath::AddNote(CNote *pNote)
{
	ASSERT_RET(pNote);

	m_notes.insert(pNote);
}

void CNotePath::DelNote(CNote *pNote)
{
	ASSERT_RET(pNote);

	m_notes.erase(pNote);
}

int CNotePath::SplitPath(const string &sName, vector<string> &vsPath)
{
	int iDeepth = 0;
	string::size_type iPos = 0;

	// 略过首字符可能是/
	if (sName[0] == PATH_SEP)
	{
		++iPos;
	}

	while (iPos < sName.size())
	{
		string::size_type iNext = sName.find(PATH_SEP, iPos);
		if (iNext != string::npos)
		{
			if (iNext > iPos)
			{
				vsPath.push_back(sName.substr(iPos, iNext - iPos));
				++iDeepth;
			}
			iPos = iNext + 1;
		}
		else
		{
			vsPath.push_back(sName.substr(iPos));
			++iDeepth;
			break;
		}
	}

	return iDeepth;
}

bool CNotePath::ValidPathName(const string &sName)
{
	static const char *INVALID_PATHNAME_CHAR = "/ #&";
	if (sName.find_first_of(INVALID_PATHNAME_CHAR) != string::npos)
	{
		return false;
	}
	else
	{
		return true;
	}
}

int CNotePath::CountTagDown()
{
	int iCount = m_children.size();

	for (auto it = m_children.begin(); it != m_children.end(); ++it)
	{
		if (it->second)
		{
			iCount += it->second->CountTagDown();
		}
	}

	return iCount;
}

int CNotePath::CountTagDown(map<string, int> &vmTags)
{
	int iCount = m_children.size();

	string sFullName = RelativeName();
	string sChildTag;

	for (auto it = m_children.begin(); it != m_children.end(); ++it)
	{
		if (!it->second)
		{
			continue;
		}

		if (sFullName.empty())
		{
			sChildTag = it->first;
		}
		else
		{
			sChildTag = sFullName + PATH_SEP + it->first;
		}

		// 该子标签所含日记数
		vmTags[sChildTag] = it->second->m_notes.size();

		// 深度优先递归
		iCount += it->second->CountTagDown(vmTags);
	}

	return iCount;
}

EINT CNotePath::MakeRealPath(const string &sRootdir)
{
	if (m_children.empty())
	{
		return 0;
	}

	string sFullPath;
	if (!m_parent)
	{
		sFullPath = sRootdir;
	}
	else
	{
		sFullPath = sRootdir + PATH_SEP + FullName();
	}

	// 目录已经存在
	if (access(sFullPath.c_str(), F_OK) == 0)
	{
		return OK;
	}

	EINT iRet = mkdir(sFullPath.c_str(), NOTE_TAGS_DIR_MODE);
	if (iRet != OK)
	{
		LOG("fails to mkdir: %s", sFullPath.c_str());
	}

	return iRet;
}

EINT CNotePath::SaveTagFile(const string &sRootdir)
{
	if (m_notes.empty())
	{
		return OK;
	}

	string sFullName = sRootdir + PATH_SEP + FullName() + NOTE_TAG_FILE_SUFFIX;

	std::ofstream fout(sFullName);
	if (!fout)
	{
		LOG("fails to open to write tag file: %s", sFullName.c_str());
		fout.close();
		return NOK;
	}

	for (auto it = m_notes.begin(); it != m_notes.end(); ++it)
	{
		if (*it == NULL)
		{
			continue;
		}
		
		string sLine = (*it)->ListLine();
		fout << sLine << std::endl;
	}

	fout.close();
	return OK;
}

EINT CNotePath::BuildTagTree(const string &sRootdir)
{
	EINT iRet = OK;

	iRet = MakeRealPath(sRootdir);
	if (iRet != OK)
	{
		LOG("abort build tag tree at: %s", m_name.c_str());
		return iRet;
	}

	iRet = SaveTagFile(sRootdir);
	if (iRet != OK)
	{
		LOG("abort build tag tree at: %s", m_name.c_str());
		return iRet;
	}

	for (auto it = m_children.begin(); it != m_children.end(); ++it)
	{
		CNotePath *pChild = it->second;
		if (pChild == NULL)
		{
			continue;
		}

		iRet = pChild->BuildTagTree(sRootdir);
		if (iRet != OK)
		{
			LOG("abort build tag tree at: %s", m_name.c_str());
			return iRet;
		}
	}

	return OK;
}

CNotePath::CNotePath(const CNotePath &that)// =delete
{
}

