#include <stdio.h>
#include <stdbool.h>

double myfoobar(double x)
{
    printf("in myfoobar--\n");
    return x*2;
}

int testCharType(const char ch)
{
    printf("char is %c \n", ch);
}

int testBoolType(const bool x)
{
    printf("bool is %s \n", x?"true":"false");
}

int testStrType(const char *s)
{
    char buff[5];
    buff[0] = s[0];
    buff[1] = s[1];
    buff[2] = s[2];
    buff[3] = s[3];
    buff[4] = '\0';
    printf("str is %s \n", buff);
}
