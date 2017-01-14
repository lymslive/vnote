#include "CNotePath.h"
#include "commdef.h"

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

CNotePath::CNotePath(const CNotePath &that)// =delete
{
}

