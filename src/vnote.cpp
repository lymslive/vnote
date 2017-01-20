// 总入口文件
#ifdef MAIN_APP
#include "CNoteApp.h"
int main(int argc, char *argv[])
{
	CNoteApp jApp;
	jApp.SetOption();
	jApp.DealOption(argc, argv);
	jApp.StartLoop();

	return 0;
}
#endif
