#include "CPlainDate.h"

CPlainDate::CPlainDate(DINT iDate)
{
	if (iDate <= 10000000)
	{
		return;
	}

	m_year = iDate / 10000;
	iDate = iDate % 10000;

	m_month = iDate / 100;
	iDate = iDate % 100;

	m_day = iDate;

	if (!IsValid())
	{
		m_year = m_month = m_day = 0;
	}
}

CPlainDate::CPlainDate(int iYear, int iMonth, int iDay) : m_year(iYear), m_month(iMonth), m_day(iDay)
{
	if (!IsValid())
	{
		m_year = m_month = m_day = 0;
	}
}

bool CPlainDate::IsValid() const
{
	if (!(m_year > 0) || !(m_month >= 1 && m_month <= 12)
			|| m_day < 0 || m_day > EndDay(m_month, m_year))
	{
		return false;
	}

	return true;
}

CPlainDate& CPlainDate::NextDay(int iShift)
{
	if (iShift > 0)
	{
		m_day += iShift;
		if (m_day > EndDay(m_month, m_year))
		{
			m_month ++;
			if (m_month > 12)
			{
				m_year ++;
				m_month = 1;
			}
			m_day = 1;
		}
	}
	else if (iShift < 0)
	{
		m_day += iShift;
		if (m_day <= 0)
		{
			m_month --;
			if (m_month <= 0)
			{
				m_year --;
				m_month = 12;
			}
			m_day = EndDay(m_month, m_year);
		}
	}

	return *this;
}

CPlainDate& CPlainDate::NextMonth(int iShift)
{
	m_month += iShift;

	if (m_month > 12)
	{
		m_year ++;
		m_month = 1;
	}
	else if (m_month < 0)
	{
		m_year --;
		m_month = 12;
	}

	// 月份变化，最大日期可能失效
	int iEndDay = EndDay(m_month, m_year);
	if (m_day > iEndDay)
	{
		m_day = iEndDay;
	}

	return *this;
}

CPlainDate& CPlainDate::NextYear(int iShift)
{
	m_year += iShift;

	return *this;
}

CPlainDate CPlainDate::operator+(int iShift)
{
	CPlainDate oDate(*this);
	return oDate.NextDay(iShift);
}

CPlainDate CPlainDate::operator-(int iShift)
{
	CPlainDate oDate(*this);
	return oDate.NextDay(-iShift);
}

CPlainDate CPlainDate::operator++(int)
{
	CPlainDate oDate(*this);
	return oDate.NextDay(1);
}

CPlainDate CPlainDate::operator--(int)
{
	CPlainDate oDate(*this);
	return oDate.NextDay(-1);
}

bool CPlainDate::IsLargeYear(int iYear)
{
	return ((iYear % 4 == 0) && (iYear % 100 != 0)) || (iYear % 400 == 0);
}

int CPlainDate::EndDay(int iMonth, int iYear)
{
	static int arriDays[1+12] = {12, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

	if (iMonth < 0 || iMonth > 12)
	{
		return 0;
	}

	if (iYear <= 0 || iMonth != 2)
	{
		return arriDays[iMonth];
	}
	else if (IsLargeYear(iYear)) // 闰年2月
	{
		return arriDays[iMonth] + 1;
	}
	else
	{
		return arriDays[iMonth];
	}
}

DINT CPlainDate::MakeData(int iYear, int iMonth, int iDay)
{
	CPlainDate oDate(iYear, iMonth, iDay);
	return static_cast<DINT>(oDate);
}

DINT CPlainDate::AddDay(DINT iDate, int iShift)
{
	CPlainDate oDate(iDate);
	oDate.NextDay(iShift);
	return static_cast<DINT>(oDate);
}

DINT CPlainDate::AddMonth(DINT iDate, int iShift)
{
	CPlainDate oDate(iDate);
	oDate.NextMonth(iShift);
	return static_cast<DINT>(oDate);
}

DINT CPlainDate::AddYear(DINT iDate, int iShift)
{
	CPlainDate oDate(iDate);
	oDate.NextYear(iShift);
	return static_cast<DINT>(oDate);
}

bool CPlainDate::CheckDate(DINT iDate)
{
	CPlainDate oDate(iDate);
	return oDate.IsValid();
}

#ifdef CPLAINDATE_TEST

#include <iostream>
int main()
{
	using std::cout;
	using std::endl;

	DINT iDate = CPlainDate::MakeData(1985, 3, 3);
	cout << (iDate == 19850303) << " " << iDate << endl;

	iDate = CPlainDate::AddDay(iDate, 1);
	cout << (iDate == 19850304) << " " << iDate << endl;

	iDate = CPlainDate::AddMonth(iDate, 1);
	cout << (iDate == 19850404) << " " << iDate << endl;

	iDate = CPlainDate::AddYear(iDate, -1);
	cout << (iDate == 19840404) << " " << iDate << endl;

	// 闰年
	iDate = CPlainDate::AddMonth(iDate, -1);
	iDate = CPlainDate::AddDay(iDate, -4);
	cout << (iDate == 19840229) << " " << iDate << endl;

	// 无效日期
	DINT jDate = CPlainDate::MakeData(1985, 13, 34);
	CPlainDate oDate(1985, 13, 34);
	if (!oDate)
	{
		cout << "invalid date 19851334" << " " << jDate << endl;
	}

	return 0;
}
#endif
