#include "CNoteApp.h"
#include "stdlib.h"
#include "CLogTool.h"
#include "CNoteQuery.h"

CNoteApp::CNoteApp() : m_pQuery(NULL), m_bMainLoop(true)
{
}

CNoteApp::~CNoteApp()
{
	if (m_pQuery)
	{
		delete m_pQuery;
		m_pQuery = NULL;
	}
}

void CNoteApp::SetOption()
{
	m_option.add<string>("dir", 'd', "Notebook directory", true, ".");
	m_option.add<string>("log", 'g', "Log file", false, "");
	m_option.add("tag", 't', "Create tag tree");
	m_option.add("cache", 'c', "Create cache as notebook db");
	m_option.add("use-cache", 'C', "Use cache to build notebook");
	m_option.add("Quit", 'Q', "Quit without interactive mode");
	m_option.add("interact", 'i', "Enter interactive mode");
}

bool CNoteApp::DealOption(int argc, char *argv[])
{
	m_option.parse_check(argc, argv);

	string sBasedir = m_option.get<string>("dir");
	string sLogFile = m_option.get<string>("log");

	ICLOGTOOL->SetLogFile(sLogFile);

	bool bUseCache = m_option.exist("use-cache");
	m_notebook.ImportFromDir(sBasedir, bUseCache);
	cout << m_notebook.Desc() << endl;

	if (m_option.exist("tag"))
	{
		m_notebook.OutputTagTree();
	}

	if (m_option.exist("cache"))
	{
		m_notebook.OutputCache();
	}

	m_pQuery = new CNoteQuery(&m_notebook);
	if (!m_pQuery)
	{
		LOG("fails to allocate space for CNoteQuery!");
		return false;
	}

	if (m_option.exist("Quit"))
	{
		m_bMainLoop = false;
	}
	if (m_option.exist("interact"))
	{
		m_bMainLoop = true;
	}

	return true;
}

bool CNoteApp::PromptBefore()
{
	if (!m_bMainLoop)
	{
		return false;
	}

	cout << "query with date or tag:\n";
	return true;
}

bool CNoteApp::PromptEach()
{
	if (!m_pQuery)
	{
		return false;
	}

	cout << "Note >";
	return true;
}

bool CNoteApp::PromptAfter()
{
	return true;
}

bool CNoteApp::DealInput(const string &input)
{
	vector<string> vsInput;
	if (SplitInput(input, vsInput) <= 0)
	{
		LOG("No input words?");
		return true;
	}

	int iCount = m_pQuery->Query(vsInput);
	if (iCount <= 0)
	{
		cerr << "Query fail, No note found!" << endl;
		return true;
	}

	const VPNOTE *pNoteSet = &m_pQuery->LastResult();
	int iMaxView = 10;

	if (pNoteSet)
	{
		cout << "Note found: " << pNoteSet->size() << endl;
		int i = 0;
		for (auto it = pNoteSet->begin(); it != pNoteSet->end(); ++it)
		{
			const CNote *pNote = *it;
			ASSERT_RET(pNote, true);
			cout << *pNote << endl;

			if (++i > iMaxView)
			{
				break;
			}
		}
	}
	else
	{
		cerr << "No note found!" << endl;
	}

	return true;
}

int CNoteApp::SplitInput(const string &sInput, vector<string> &vsWords)
{
	int iCount = 0;
	string::size_type iPos = 0;

	// 略过前导空格
	while (sInput[iPos] == CHAR_SPACE)
	{
		++iPos;
	}

	while (iPos < sInput.size())
	{
		// 下一个空格
		string::size_type iNext = sInput.find(CHAR_SPACE, iPos);
		if (iNext != string::npos)
		{
			if (iNext > iPos)
			{
				vsWords.push_back(sInput.substr(iPos, iNext - iPos));
				++iCount;
			}

			// 略过连续空格
			while (sInput[iNext] == CHAR_SPACE) { ++iNext; }
			iPos = iNext;
		}
		else
		{
			vsWords.push_back(sInput.substr(iPos));
			++iCount;
			break;
		}
	}

	return iCount;
}
