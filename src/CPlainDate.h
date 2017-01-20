#ifndef CPLAINDATE_H__
#define CPLAINDATE_H__
// #define CPLAINDATE_TEST

// 表示日期的整数 yyyymmdd
typedef int DINT;

// 表示日期的简易类
class CPlainDate
{
public:
	// 构造函数
	explicit CPlainDate (DINT iDate = 0);
	CPlainDate (int iYear, int iMonth, int iDay);

	// 日期有效性判断
	bool IsValid() const;
	//*explicit*/ operator bool() { return IsValid(); }

	// 转为整数表示法，8位整数 yyyymmdd
	/*explicit*/ operator DINT() const { return IsValid() ? (m_year * 10000 + m_month * 100 + m_day) : 0; }

	// 日期分量
	int Year() { return m_year; }
	int Month() { return m_month; }
	int Day() { return m_day; }

	// 该日期对象自身偏移方法（只适于小偏移）
	CPlainDate& NextDay(int iShift);
	CPlainDate& NextMonth(int iShift);
	CPlainDate& NextYear(int iShift);

	// 重载加减法，按天数偏移
	CPlainDate operator+(int iShift);
	CPlainDate operator-(int iShift);

	CPlainDate& operator++() { return NextDay(1); }
	CPlainDate& operator--() { return NextDay(-1); }
	CPlainDate operator++(int);
	CPlainDate operator--(int);

private:
	// C++11 特性，g++ 老版本不支持
	short m_year/* = 0*/;
	char m_month/* = 0*/;
	char m_day/* = 0*/;

public:
	// 是否闰年
	inline static bool IsLargeYear(int iYear);
	// 该月的最大天数
	static int EndDay(int iMonth, int iYear = 0);

	// 静态方法处理整数表示法的日期
	static DINT MakeData(int iYear, int iMonth, int iDay);
	static DINT AddDay(DINT iDate, int iShift);
	static DINT AddMonth(DINT iDate, int iShift);
	static DINT AddYear(DINT iDate, int iShift);
	static bool CheckDate(DINT iDate);
};

#endif /* end of include guard: CPLAINDATE_H__ */
