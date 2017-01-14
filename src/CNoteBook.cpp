#include "CNoteBook.h"
#include "CNote.h"
#include "CNotePath.h"
#include "CNoteParser.h"
#include <algorithm>

CNoteBook::CNoteBook() : m_parser(NULL), m_rootPath(NULL)
{
}

CNoteBook::CNoteBook(const string &sBasedir) :
	m_basedir(sBasedir),
	m_parser(NULL),
	m_rootPath(NULL)
{
	m_parser = new CNoteParser(m_basedir);
}

CNoteBook::~CNoteBook()
{
	// 删除日记
	for (auto it = m_vpNote.begin(); it != m_vpNote.end(); ++it)
	{
		CNote *pNote = *it;
		if (pNote)
		{
			delete pNote;
			// *it = NULL; // set 的 key 是常量
		}
	}

	// 删除目录树
	if (m_rootPath)
	{
		delete m_rootPath;
		m_rootPath = NULL;
	}

	if (m_parser)
	{
		delete m_parser;
		m_parser = NULL;
	}
}

void CNoteBook::ImportFromDir()
{
}

void CNoteBook::ImportFromFileList(string sFileList)
{
}

void CNoteBook::BuildDateIndex(bool bRebuild)
{
	if (!m_dateIndex.empty() && !bRebuild)
	{
		return;
	}

	m_dateIndex.clear();

	for (auto it = m_vpNote.begin(); it != m_vpNote.end(); ++it)
	{
		CNote *pNote = *it;
		ASSERT_RET(pNote);

		DINT iDate = pNote->Date();
		m_dateIndex[iDate].insert(pNote);
	}
}

void CNoteBook::BuildTagInex(bool bRebuild)
{
	if (!m_tagIndex.empty() && !bRebuild)
	{
		return;
	}

	m_tagIndex.clear();

	for (auto it = m_vpNote.begin(); it != m_vpNote.end(); ++it)
	{
		CNote *pNote = *it;
		ASSERT_RET(pNote);

		// 多标签
		const set<string> vTag = pNote->Tag();
		for (auto jt = vTag.begin(); jt != vTag.end(); ++jt)
		{
			const string &sTag = *jt;
			m_tagIndex[sTag].insert(pNote);
		}
	}
}

void CNoteBook::BuildPathTree(bool bRebuild)
{
	if (m_rootPath)
	{
		if (!bRebuild)
		{
			return;
		}
		else
		{
			delete m_rootPath;
			m_rootPath = NULL;
		}
	}

	// 新建一个根目录结点
	m_rootPath = new CNotePath("/");

	for (auto it = m_vpNote.begin(); it != m_vpNote.end(); ++it)
	{
		CNote *pNote = *it;
		ASSERT_RET(pNote);

		// 为每个标签路径创建目录结点，添加该日记指针
		const set<string> vTag = pNote->Tag();
		for (auto jt = vTag.begin(); jt != vTag.end(); ++jt)
		{
			const string &sTag = *jt;
			CNotePath *pChild = m_rootPath->AddChildPath(sTag);
			if (pChild)
			{
				pChild->AddNote(pNote);
			}
			else
			{
				//log
			}
		}
	}
}

CNote * CNoteBook::AddNewNote()
{
	CNote *pNote = new CNote();
	if (!pNote)
	{
		return NULL;
	}

	m_vpNote.insert(pNote);

	return pNote;
}

bool CNoteBook::RemoveNote(CNote *pNote)
{
	ASSERT_RET(pNote, false);
	pNote->MarkDelete();
	return pNote->IsDeleted();
}

void CNoteBook::AddNoteTag(CNote *pNote, string sTag)
{
	ASSERT_RET(pNote);

	// 先给日志本身加标签
	if (pNote->InTag(sTag))
	{
		return;
	}
	pNote->AddTag(sTag);

	// 添加至标签索引
	m_tagIndex[sTag].insert(pNote);

	// 添加至目录树索引
	CNotePath *pChild = m_rootPath->AddChildPath(sTag);
	if (pChild)
	{
		pChild->AddNote(pNote);
	}
	else
	{
		//log
	}
}

void CNoteBook::DelNoteTag(CNote *pNote, string sTag)
{
	ASSERT_RET(pNote);

	// 删除日志的相应标签
	if (!pNote->InTag(sTag))
	{
		return;
	}
	pNote->RmTag(sTag);

	// 索引存在
	if (m_tagIndex.count(sTag) > 0)
	{
		m_tagIndex[sTag].erase(pNote);
	}

	CNotePath *pChild = m_rootPath->ChildPath(sTag);
	if (pChild)
	{
		pChild->DelNote(pNote);
	}
}

void CNoteBook::ChangeNoteDate(CNote *pNote, DINT iDate)
{
	ASSERT_RET(pNote);

	// 从旧日期索引中删除
	DINT iOldDate = pNote->Date();
	if (m_dateIndex.count(iOldDate))
	{
		m_dateIndex[iOldDate].erase(pNote);
	}

	// 修改日期
	pNote->ReDate(iDate);
	m_dateIndex[iDate].insert(pNote);
}

void CNoteBook::ChangeNoteTitle(CNote *pNote, const string &sTitle)
{
	ASSERT_RET(pNote);
	pNote->ReTitle(sTitle);
}

CNoteBook::CNoteBook(const CNoteBook &that) // =delete
{
}

