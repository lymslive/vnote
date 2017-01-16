# 选择编译入口 main 代码，一些类文件中有独立的测试 main 函数
SELECT = -DCNOTE_TEST

# C++ 编译器
CXX = g++ -std=c++0x
# 编译选项
CPPFLAGS += -g
# 也是编译选项
CXXFLAGS += $(SELECT)

# cpp 的隐式规则为 $(CXX) $(CPPFLAGS) $(CXXFLAGS) -c
objects := $(patsubst %.cpp, %.o, $(wildcard *.cpp))

test : $(objects)
	$(CXX) -o test.out $(objects)

all:
	$(CXX) -o vnote.out $(objects)

.PHONY: clean
clean:
	rm *.o *.out
