#include "CNoteQuery.h"
#include "CNoteBook.h"
#include "CLogTool.h"
#include "vnote.h"
#include "stdlib.h"
#include <algorithm>

bool CNoteQuery::SetBook(CNoteBook *pNoteBook)
{
	ASSERT_RET(pNoteBook, false);
	m_pCurBook = pNoteBook;
	return true;
}

int CNoteQuery::Query(const vector<string> &vsInput)
{
	ASSERT_RET(m_pCurBook, 0);
	ASSERT_RET(vsInput.size() > 0, 0);

	SQueryFace stFace;
	for (auto it = vsInput.begin(); it != vsInput.end(); ++it)
	{
		DINT iDate = atoi((*it).c_str());
		if (iDate <= 0)
		{
			stFace.sText = *it;
			continue;
		}

		if (stFace.dBegin <= 0)
		{
			stFace.dBegin = iDate;
		}
		else
		{
			stFace.dEnd = iDate;
		}
	}

	return Query(stFace);
}

int CNoteQuery::Query(SQueryFace &stFace)
{
	ASSERT_RET(m_pCurBook, 0);

	if (!stFace.sText.empty())
	{
		return Query(stFace.sText, stFace.dBegin, stFace.dEnd);
	}

	return QueryDate(stFace.dBegin, stFace.dEnd);
}

int CNoteQuery::Query(const string &sText, DINT dBegin, DINT dEnd)
{
	ASSERT_RET(m_pCurBook, 0);
	if (sText.empty())
	{
		return QueryDate(dBegin, dEnd);
	}

	char cPrefix = sText[0];
	if (cPrefix == PREFIX_TAG)
	{
		if (sText.size() <= 1)
		{
			LOG("try to query empty tag?");
			return 0;
		}
		return QueryTag(sText.substr(1), dBegin, dEnd);
	}
	else if (cPrefix == PREFIX_TITLE)
	{
		if (sText.size() <= 1)
		{
			LOG("try to query empty title?");
			return 0;
		}
		return QueryTitle(sText.substr(1), dBegin, dEnd);
	}

	int iTagQuery = QueryTag(sText, dBegin, dEnd);
	if (iTagQuery > 0)
	{
		return iTagQuery;
	}

	return QueryTitle(sText, dBegin, dEnd);
}

int CNoteQuery::QueryTag(const string &sTag, DINT dBegin, DINT dEnd)
{
	ASSERT_RET(m_pCurBook, 0);
	if (sTag.empty())
	{
		return QueryDate(dBegin, dEnd);
	}

	const VPNOTE *pTagNotes = m_pCurBook->TagIndex(sTag);
	if (!pTagNotes || pTagNotes->empty())
	{
		return 0;
	}

	m_vpResult.clear();
	FilterDate(pTagNotes, dBegin, dEnd);

	return m_vpResult.size();
}

int CNoteQuery::QueryTitle(const string &sTitle, DINT dBegin, DINT dEnd)
{
	ASSERT_RET(m_pCurBook, 0);
	if (sTitle.empty())
	{
		return QueryDate(dBegin, dEnd);
	}

	VPNOTE vpNotes;
	for (auto it = m_pCurBook->GetNotes().begin(); it != m_pCurBook->GetNotes().end(); ++it)
	{
		string sNoteTitle = (*it)->Title();
		if (sNoteTitle.find(sTitle) != string::npos)
		{
			vpNotes.insert(*it);
		}
	}

	if (vpNotes.empty())
	{
		return 0;
	}

	m_vpResult.clear();
	FilterDate(&vpNotes, dBegin, dEnd);

	return m_vpResult.size();
}

int CNoteQuery::QueryDate(DINT dBegin, DINT dEnd)
{
	ASSERT_RET(m_pCurBook, 0);

	// 参数检查
	if (dBegin <= 0)
	{
		LOG("Not specific any text or date to search!");
		return 0;
	}

	if (dEnd <= 0)
	{
		dEnd = dBegin;
	}

	if (dBegin > dEnd)
	{
		std::swap(dBegin, dEnd);
	}

	if (CPlainDate::CheckDate(dBegin) == false)
	{
		LOG("Invalid date: %d", dBegin);
		return 0;
	}

	if (dEnd != dBegin && CPlainDate::CheckDate(dEnd) == false)
	{
		LOG("Invalid date: %d", dEnd);
		return 0;
	}

	// 日期索引
	const map<DINT, VPNOTE> &jDateIndex = m_pCurBook->GetDateMap();

	if (dBegin == dEnd) // 只查这天的日记
	{
		auto itDate = jDateIndex.find(dBegin);
		if (itDate == jDateIndex.end())
		{
			return 0;
		}

		// 复制到结果集中
		m_vpResult.clear();
		// std::insert_iterator<VPNOTE> itInsert(m_vpResult, m_vpResult.begin());
		auto itInsert = std::inserter(m_vpResult, m_vpResult.begin());
		std::copy(itDate->second.begin(), itDate->second.end(), itInsert);
	}
	else // 查一个日期范围
	{
		auto itBegin = jDateIndex.lower_bound(dBegin);
		if (itBegin == jDateIndex.end())
		{
			return 0;
		}
		auto itEnd = jDateIndex.upper_bound(dEnd);

		m_vpResult.clear();
		auto itInsert = std::inserter(m_vpResult, m_vpResult.begin());

		for (auto itDate = itBegin; itDate != itEnd; ++itDate)
		{
			std::copy(itDate->second.begin(), itDate->second.end(), itInsert);
		}
	}

	return m_vpResult.size();
}

int CNoteQuery::FilterDate(const VPNOTE *pTagNotes, DINT dBegin, DINT dEnd)
{
	int iOldSize = m_vpResult.size();

	if (dBegin <= 0) // 未限定日期
	{
		auto itInsert = std::inserter(m_vpResult, m_vpResult.begin());
		std::copy(pTagNotes->begin(), pTagNotes->end(), itInsert);
	}
	else if (dBegin > 0 && dEnd <= 0 || dBegin == dEnd) // 单日期
	{
		for (auto it = pTagNotes->begin(); it != pTagNotes->end(); ++it)
		{
			if ((*it)->Date() == dBegin)
			{
				m_vpResult.insert(*it);
			}
		}
	}
	else // 日期范围
	{
		if (dBegin > dEnd)
		{
			std::swap(dBegin, dEnd);
		}
		for (auto it = pTagNotes->begin(); it != pTagNotes->end(); ++it)
		{
			if ((*it)->Date() >= dBegin && (*it)->Date() <= dEnd)
			{
				m_vpResult.insert(*it);
			}
		}
	}

	return m_vpResult.size() - iOldSize;
}

