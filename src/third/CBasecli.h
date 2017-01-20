#ifndef CBASECLI_H__
#define CBASECLI_H__

#include "cmdline.h"

class CBasecli
{
public:
	CBasecli(){ };
	virtual ~CBasecli(){ };

	virtual void SetOption() = 0;
	virtual bool DealOption(int argc, char *argv[]) = 0;

	virtual void StartLoop(){
		if (!PromptBefore()) return;
		std::string input;
		while (PromptEach() && std::getline(std::cin, input)){
			if (!DealInput(input)) break;
		}
		PromptAfter();
	}

	virtual bool PromptBefore() { return true; }
	virtual bool PromptEach() { return true; }
	virtual bool PromptAfter() { return true; }
	virtual bool DealInput(const std::string &input){
		std::cout << input << std::endl;
		return true;
	}

protected:
	cmdline::parser m_option;
};

#endif /* end of include guard: CBASECLI_H__ */
