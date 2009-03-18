#include <stdio.h>

#define kANSIEscapeReset 	"\033[0m"
#define kANSIEscapeBold 	"\033[01m"

#define kANSIEscapeRed 		"\033[31m"
#define kANSIEscapeGreen 	"\033[32m"
#define kANSIEscapeYellow 	"\033[33m"
#define kANSIEscapeBlue 	"\033[34m"
#define kANSIEscapeMagenta 	"\033[35m"
#define kANSIEscapeCyan		"\033[36m"
#define kANSIEscapeWhite	"\033[37m"
#define kANSIEscapeFgReset	"\033[39m"

#define kANSIEscapeBgRed 		"\033[41m"
#define kANSIEscapeBgGreen 		"\033[42m"
#define kANSIEscapeBgYellow 	"\033[43m"
#define kANSIEscapeBgBlue 		"\033[44m"
#define kANSIEscapeBgMagenta 	"\033[45m"
#define kANSIEscapeBgCyan		"\033[46m"
#define kANSIEscapeBgWhite		"\033[47m"
#define kANSIEscapeBgReset		"\033[49m"


int main(int argc, char *argv[])
{
	printf("basic colors:\n");
	printf("%sred %sgreen%s %syellow%s and %sblue.\n", kANSIEscapeRed, kANSIEscapeGreen, kANSIEscapeReset, kANSIEscapeYellow, kANSIEscapeReset, kANSIEscapeBlue);
	printf("%smagenta %scyan%s and %swhite%s.\n", kANSIEscapeMagenta, kANSIEscapeCyan, kANSIEscapeReset, kANSIEscapeWhite, kANSIEscapeReset);
	printf("\n");
	
	printf("background colors:\n");
	printf("%sred %sgreen%s %syellow%s and %sblue.\n", kANSIEscapeBgRed, kANSIEscapeBgGreen, kANSIEscapeReset, kANSIEscapeBgYellow, kANSIEscapeReset, kANSIEscapeBgBlue);
	printf("%smagenta %scyan%s and %swhite%s.\n", kANSIEscapeBgMagenta, kANSIEscapeBgCyan, kANSIEscapeReset, kANSIEscapeBgWhite, kANSIEscapeReset);
	printf("\n");
	
	printf("overlapping foreground and background colors:\n");
	printf("%sgreen bg with %syellow fg%s still green bg%s bg reset", kANSIEscapeBgGreen, kANSIEscapeYellow, kANSIEscapeFgReset, kANSIEscapeBgReset);
	printf("\n");
	
	return 0;
}