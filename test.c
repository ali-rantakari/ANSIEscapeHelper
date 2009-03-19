#include <stdio.h>

#define kANSIEscapeReset 	"\033[0m"
#define kANSIEscapeResetAlt	"\033[m"

#define kANSIEscapeItalic 	"\033[3m"

#define kANSIEscapeUnderlineSingle 	"\033[4m"
#define kANSIEscapeUnderlineDouble 	"\033[21m"
#define kANSIEscapeUnderlineNone 	"\033[24m"

#define kANSIEscapeBold 	"\033[1m"
#define kANSIEscapeBoldOff 	"\033[22m"

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
	printf("%sgreen bg with %syellow fg%s still green bg%s bg reset\n", kANSIEscapeBgGreen, kANSIEscapeYellow, kANSIEscapeFgReset, kANSIEscapeBgReset);
	printf("\n");
	
	printf("test alternative reset:\n");
	printf("%sred and now...%sreset!\n", kANSIEscapeRed, kANSIEscapeResetAlt);
	printf("\n");
	
	printf("bold and underline:\n");
	printf("start underline:%shello i am %sdoubly%s underlined %sand bold%s, %soccasionally.%s sometimes not underlined anymore.%s\n", kANSIEscapeUnderlineSingle, kANSIEscapeUnderlineDouble, kANSIEscapeUnderlineSingle, kANSIEscapeBold, kANSIEscapeBoldOff, kANSIEscapeBlue, kANSIEscapeUnderlineNone, kANSIEscapeReset);
	printf("\n");
	
	printf("And some normal text here.");
	printf("\n");
	
	return 0;
}