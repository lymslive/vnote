#ifndef CNOTEAPP_H__
#define CNOTEAPP_H__

#include "third/CBasecli.h"
#include "CNoteBook.h"

class CNoteQuery;

class CNoteApp : public CBasecli
{
public:
	CNoteApp();
	virtual ~CNoteApp();

	virtual void SetOption();
	virtual bool DealOption(int argc, char *argv[]);

	virtual bool PromptBefore();
	virtual bool PromptEach();
	virtual bool PromptAfter();
	virtual bool DealInput(const string &input);

private:
	static int SplitInput(const string &sInput, vector<string> &vsWords);

private:
	CNoteBook m_notebook;
	CNoteQuery *m_pQuery;
};

#endif /* end of include guard: CNOTEAPP_H__ */
