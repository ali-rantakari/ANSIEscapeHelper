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

#define kANSIEscapeBrightBlack 		"\033[90m"
#define kANSIEscapeBrightRed 		"\033[91m"
#define kANSIEscapeBrightGreen 		"\033[92m"
#define kANSIEscapeBrightYellow 	"\033[93m"
#define kANSIEscapeBrightBlue 		"\033[94m"
#define kANSIEscapeBrightMagenta 	"\033[95m"
#define kANSIEscapeBrightCyan		"\033[96m"
#define kANSIEscapeBrightWhite		"\033[97m"

#define kANSIEscapeBgBrightBlack	"\033[100m"
#define kANSIEscapeBgBrightRed 		"\033[101m"
#define kANSIEscapeBgBrightGreen 	"\033[102m"
#define kANSIEscapeBgBrightYellow 	"\033[103m"
#define kANSIEscapeBgBrightBlue 	"\033[104m"
#define kANSIEscapeBgBrightMagenta 	"\033[105m"
#define kANSIEscapeBgBrightCyan		"\033[106m"
#define kANSIEscapeBgBrightWhite	"\033[107m"


int main(int argc, char *argv[])
{
	/*
	printf("alternative CSI:\n");
	printf("\23344mhello\233m\n");
	printf("\n");
	*/
	
	printf("foreground colors:\n");
	printf("%sred %sgreen%s %syellow%s and %sblue.\n", kANSIEscapeRed, kANSIEscapeGreen, kANSIEscapeReset, kANSIEscapeYellow, kANSIEscapeReset, kANSIEscapeBlue);
	printf("%smagenta %scyan%s and %swhite%s.\n", kANSIEscapeMagenta, kANSIEscapeCyan, kANSIEscapeReset, kANSIEscapeWhite, kANSIEscapeReset);
	printf("\n");
	
	printf("bright foreground colors:\n");
	printf("%sred %sgreen%s %syellow%s and %sblue.\n", kANSIEscapeBrightRed, kANSIEscapeBrightGreen, kANSIEscapeReset, kANSIEscapeBrightYellow, kANSIEscapeReset, kANSIEscapeBrightBlue);
	printf("%smagenta %scyan%s and %swhite%s. also %sblack%s.\n", kANSIEscapeBrightMagenta, kANSIEscapeBrightCyan, kANSIEscapeReset, kANSIEscapeBrightWhite, kANSIEscapeReset, kANSIEscapeBrightBlack, kANSIEscapeReset);
	printf("\n");
	
	printf("background colors:\n");
	printf("%sred %sgreen%s %syellow%s and %sblue.\n", kANSIEscapeBgRed, kANSIEscapeBgGreen, kANSIEscapeReset, kANSIEscapeBgYellow, kANSIEscapeReset, kANSIEscapeBgBlue);
	printf("%smagenta %scyan%s and %swhite%s.\n", kANSIEscapeBgMagenta, kANSIEscapeBgCyan, kANSIEscapeReset, kANSIEscapeBgWhite, kANSIEscapeReset);
	printf("\n");
	
	printf("bright background colors:\n");
	printf("%sred %sgreen%s %syellow%s and %sblue.\n", kANSIEscapeBgBrightRed, kANSIEscapeBgBrightGreen, kANSIEscapeReset, kANSIEscapeBgBrightYellow, kANSIEscapeReset, kANSIEscapeBgBrightBlue);
	printf("%smagenta %scyan%s and %swhite%s. also %sblack%s.\n", kANSIEscapeBgBrightMagenta, kANSIEscapeBgBrightCyan, kANSIEscapeReset, kANSIEscapeBgBrightWhite, kANSIEscapeReset, kANSIEscapeBgBrightBlack, kANSIEscapeReset);
	printf("\n");
	
	printf("bright color reset test:\n");
	printf("%sgreen%s reset %sblue bg%s reset.\n", kANSIEscapeBrightGreen, kANSIEscapeFgReset, kANSIEscapeBgBrightBlue, kANSIEscapeBgReset);
	printf("%sbright %sand normal%s. %sbright bg %sand normal.%s\n", kANSIEscapeBrightCyan, kANSIEscapeCyan, kANSIEscapeFgReset, kANSIEscapeBgBrightRed, kANSIEscapeBgRed, kANSIEscapeBgReset);
	printf("\n");
	
	printf("overlapping foreground and background colors:\n");
	printf("%sgreen bg with %syellow fg%s still green bg%s bg reset\n", kANSIEscapeBgGreen, kANSIEscapeYellow, kANSIEscapeFgReset, kANSIEscapeBgReset);
	printf("\n");
	
	printf("test italic & alternative reset:\n");
	printf("hello %si am italic!%s ..still? %sred and now...%sreset!\n", kANSIEscapeItalic, kANSIEscapeItalic, kANSIEscapeRed, kANSIEscapeResetAlt);
	printf("\n");
	
	printf("bold and underline:\n");
	printf("start underline:%shello i am %sdoubly%s underlined %sand bold%s, %soccasionally.%s sometimes not underlined anymore.%s\n", kANSIEscapeUnderlineSingle, kANSIEscapeUnderlineDouble, kANSIEscapeUnderlineSingle, kANSIEscapeBold, kANSIEscapeBoldOff, kANSIEscapeBlue, kANSIEscapeUnderlineNone, kANSIEscapeReset);
	printf("\n");
	
	printf("several codes in one sequence:\n");
	printf("\033[46;31;4mlots of formats at once%s\n", kANSIEscapeResetAlt);
	printf("\n");
	
	printf("non-SGR control sequences (after 'd', delete 2 chars backwards):\n");
	printf("abcd\033[2Defg\n");
	printf("\n");
	
	printf("And some normal text here.");
	printf("\n");
	
	return 0;
}