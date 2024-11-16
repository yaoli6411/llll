#include "/home/liyao/Desktop/studylinux/kernel/print.h"

void main(void)
{
	asm ("xchg %bx,%bx");	
	put_str("OK you are welldone");
	while(1);
}
