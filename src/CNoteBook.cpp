#include "CNoteBook.h"
#include <fstream>
#include <sstream>
#include <algorithm>
#include "vnote.h"
#include "CNote.h"
#include "CNotePath.h"
#include "CNoteParser.h"
#include "CLogTool.h"
#include "CFileDir.h"
#include <sys/stat.h>
#include <unistd.h>

CNoteBook::CNoteBook() : m_rootPath(NULL), m_ready(false)
{
}

CNoteBook::CNoteBook(const string &sBasedir) :
	// m_basedir(sBasedir),
	m_rootPath(NULL),
	m_ready(false)
{
	ImportFromDir(sBasedir);
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

}

EINT CNoteBook::ImportFromDir(const string &sBasedir, bool bUseCache)
{
	if (m_ready)
	{
		LOG("this book has been ready: %s", m_basedir.c_str());
		return NOK;
	}

	if (sBasedir.empty())
	{
		LOG("try to import note book from empty named directory?");
		return NOK;
	}

	m_basedir = CFileDir::TrimTailSlash(sBasedir);

	// 从缓存中载入日记本
	if (bUseCache)
	{
		string sCacheDir = m_basedir + PATH_SEP + NOTE_CACHE_DIR;
		string sCacheFile = sCacheDir + PATH_SEP + NOTE_CACHE_FILE;
		if (access(sCacheFile.c_str(), R_OK) == 0)
		{
			return ImportFromCache(sCacheFile);
		}
	}

	// 获取文件列表
	CFileDir jDir(sBasedir + PATH_SEP + NOTE_DATE_DIR);
	vector<string> vsFileList;
	jDir.GetAllFiles(vsFileList, 0, NOTE_FILE_SUFFIX);

	return CreateNoteBook(vsFileList);
}

EINT CNoteBook::ImportFromFileList(const string &sFileList)
{
	if (sFileList.empty())
	{
		LOG("try to import notebook from empty named file-list");
		return NOK;
	}

	// 文件所在目录视为日记本目录
	string sBasedir = CFileDir::GetDirPart(sFileList);
	m_basedir = sBasedir;

	// 读入文件名列表
	vector<string> vsFileList;

	using std::ifstream;
	ifstream fin(sFileList);
	if (!fin)
	{
		LOG("fails to open note file:%s", sFileList.c_str());
		fin.close();
		return NOK;
	}

	string sLine;
	while (std::getline(fin, sLine))
	{
		if (sLine.empty())
		{
			continue;
		}
		vsFileList.push_back(sLine);
	}

	fin.close();

	return CreateNoteBook(vsFileList);
}

EINT CNoteBook::CreateNoteBook(const vector<string> &vsFileList)
{
	// 先创建所有日记
	for (auto it = vsFileList.begin(); it != vsFileList.end(); ++it)
	{
		// 过滤不合适的文件名
		if (!CNoteParser::FilterFileName(*it))
		{
			continue;
		}

		string sFileName = m_basedir + PATH_SEP + NOTE_DATE_DIR + PATH_SEP + *it;
		CNote *pNote = new CNote(sFileName);
		if (!pNote)
		{
			LOG("fails to allocate space for CNote");
			return NOK;
		}

		m_vpNote.insert(pNote);
	}

	// 创建索引
	BuildDateIndex(true);
	BuildPathTree(true);

	m_ready = true;

	return OK;
}

EINT CNoteBook::ImportFromCache(const string &sCacheFile)
{
	std::ifstream fin(sCacheFile);
	if (!fin)
	{
		LOG("fails to open note file:%s", sCacheFile.c_str());
		fin.close();
		return NOK;
	}

	EINT iRet = OK;
	string sLine;
	while (std::getline(fin, sLine))
	{
		if (sLine.empty())
		{
			continue;
		}

		CNote *pNote = new CNote();
		if (!pNote)
		{
			LOG("fails to allocate space for CNote");
			return NOK;
		}

		iRet = pNote->ReadCache(sLine);
		if (iRet != OK)
		{
			LOG("fails to read cache into note");
		}

		m_vpNote.insert(pNote);
	}

	fin.close();

	// 创建索引
	BuildDateIndex(true);
	BuildPathTree(true);

	m_ready = true;

	return OK;
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
	if (!m_rootPath)
	{
		LOG("fails to allocat space for CNotePath");
		return;
	}

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
				LOG("fails to add path for: %s", sTag.c_str());
			}
		}
	}
}

EINT CNoteBook::OutputTagTree()
{
	if (m_rootPath == NULL)
	{
		return NOK;
	}

	string sRootdir = m_basedir + PATH_SEP + NOTE_TAGS_DIR;
	return m_rootPath->BuildTagTree(sRootdir);
}

EINT CNoteBook::OutputCache()
{
	EINT iRet = OK;

	// 创建目录
	string sCacheDir = m_basedir + PATH_SEP + NOTE_CACHE_DIR;
	if (access(sCacheDir.c_str(), F_OK) != 0)
	{
		iRet = mkdir(sCacheDir.c_str(), NOTE_TAGS_DIR_MODE);
		if (iRet != OK)
		{
			LOG("fails to mkdir: %s", sCacheDir.c_str());
			return iRet;
		}
	}

	// 新建文件
	string sFileName = sCacheDir + PATH_SEP + NOTE_CACHE_FILE;
	std::ofstream fout(sFileName);
	if (!fout)
	{
		LOG("fails to open to write tag file: %s", sFileName.c_str());
		fout.close();
		return NOK;
	}

	// 写入文件
	for (auto it = m_vpNote.begin(); it != m_vpNote.end(); ++it)
	{
		CNote *pNote = *it;
		if (!pNote)
		{
			continue;
		}

		string sLine = pNote->ListLine(true);
		fout << sLine << std::endl;
	}

	fout.close();
	return OK;
}

const VPNOTE *CNoteBook::DateIndex(DINT iDate)
{
	if (m_dateIndex.count(iDate))
	{
		return &m_dateIndex[iDate];
	}
	else
	{
		return NULL;
	}
}

const VPNOTE *CNoteBook::TagIndex(const string &sTag) const
{
	if (!m_rootPath)
	{
		LOG("this Note Book has not build Path Tree");
		return NULL;
	}

	CNotePath *pChild = m_rootPath->ChildPath(sTag);
	if (pChild)
	{
		return &pChild->Notes();
	}
	else
	{
		return NULL;
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
		LOG("the note[%s] has already tag[%s]", pNote->NoteID().c_str(), sTag.c_str());
		return;
	}
	pNote->AddTag(sTag);

	// 添加至目录树索引
	CNotePath *pChild = m_rootPath->AddChildPath(sTag);
	if (pChild)
	{
		pChild->AddNote(pNote);
	}
	else
	{
		LOG("fails to add path for: %s", sTag.c_str());
	}
}

void CNoteBook::DelNoteTag(CNote *pNote, string sTag)
{
	ASSERT_RET(pNote);

	// 删除日志的相应标签
	if (!pNote->InTag(sTag))
	{
		LOG("the note[%s] donot have tag[%s]", pNote->NoteID().c_str(), sTag.c_str());
		return;
	}
	pNote->RmTag(sTag);

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

void CNoteBook::ChangeBookTag(const string &sOldTag, const string &sNewTag)
{
	// todo, 有点复杂，需同步编辑修改每个日记文件的内容
	// 重建内部对象的索引倒还好说
}

string CNoteBook::Desc() const
{
	using std::ostringstream;
	using std::endl;

	ostringstream str;
	str << "NoteBook  :  " << m_basedir << endl;
	str << "Note Count: " << m_vpNote.size() << endl;
	if (m_rootPath)
	{
		str << "Tags Count:  " << m_rootPath->CountTagDown() << endl;
	}

	return str.str();
}

CNoteBook::CNoteBook(const CNoteBook &that) // =delete
{
}

/*********** 单元测试 ***********/

#ifdef CNOTEBOOK_TEST
#include <iostream>
#include "stdlib.h"

using std::cout;
using std::cin;
using std::cerr;
using std::endl;

int main(int argc, char *argv[])
{
	if (argc < 2)
	{
		cerr << "command line argument: basedir" << endl;
		return -1;
	}

	string sBasedir(argv[1]);

	// 将整个目录读入 notebook
	CNoteBook jBook(sBasedir);
	cout << jBook.Desc() << endl;

	string sTag;
	DINT iDate = 0;
	const VPNOTE *pNoteSet = NULL;
	int iMaxView = 10;

	// 轮询日期或标签
	cout << "Input a query date or tag: ";
	while (std::getline(cin, sTag))
	{
		pNoteSet = NULL;

		iDate = atoi(sTag.c_str());
		if (iDate > 0)
		{
			pNoteSet = jBook.DateIndex(iDate);
		}
		else
		{
			pNoteSet = jBook.TagIndex(sTag);
		}

		if (pNoteSet)
		{
			cout << "note found: " << pNoteSet->size() << endl;
			int i = 0;
			for (auto it = pNoteSet->begin(); it != pNoteSet->end(); ++it)
			{
				const CNote *pNote = *it;
				if (!pNote)
				{
					cerr << "occur NULL CNote pointer in date index:" << iDate << endl;
				}
				cout << *pNote << endl;

				if (++i > iMaxView)
				{
					break;
				}
			}
		}
		else
		{
			cerr << "no note found!" << endl;
		}

		cout << "Input a query date or tag: ";
	}

	return 0;
}
#endif
