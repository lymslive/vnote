# 选择编译入口 main 代码，一些类文件中有独立的测试 main 函数
SELECT = -DCNOTEBOOK_TEST
CXXFLAGS += $(SELECT)

# C++ 编译器选项
CXX = g++ -std=c++0x
# 支持 GDB
CPPFLAGS += -g
# 非 debug 宏
CPPFLAGS += -DNDEBUG

# cpp 的隐式规则为 $(CXX) $(CPPFLAGS) $(CXXFLAGS) -c
objects := $(patsubst %.cpp, %.o, $(wildcard *.cpp))

test : $(objects)
	$(CXX) -o test.out $(objects)

all:
	$(CXX) -o vnote.out $(objects)

.PHONY: clean
clean:
	rm *.o *.out
