#import "MyController.h"


#define kANSIColorPrefKey_FgBlack	@"ansiColorsFgBlack"
#define kANSIColorPrefKey_FgWhite	@"ansiColorsFgWhite"
#define kANSIColorPrefKey_FgRed		@"ansiColorsFgRed"
#define kANSIColorPrefKey_FgGreen	@"ansiColorsFgGreen"
#define kANSIColorPrefKey_FgYellow	@"ansiColorsFgYellow"
#define kANSIColorPrefKey_FgBlue	@"ansiColorsFgBlue"
#define kANSIColorPrefKey_FgMagenta	@"ansiColorsFgMagenta"
#define kANSIColorPrefKey_FgCyan	@"ansiColorsFgCyan"
#define kANSIColorPrefKey_BgBlack	@"ansiColorsBgBlack"
#define kANSIColorPrefKey_BgWhite	@"ansiColorsBgWhite"
#define kANSIColorPrefKey_BgRed		@"ansiColorsBgRed"
#define kANSIColorPrefKey_BgGreen	@"ansiColorsBgGreen"
#define kANSIColorPrefKey_BgYellow	@"ansiColorsBgYellow"
#define kANSIColorPrefKey_BgBlue	@"ansiColorsBgBlue"
#define kANSIColorPrefKey_BgMagenta	@"ansiColorsBgMagenta"
#define kANSIColorPrefKey_BgCyan	@"ansiColorsBgCyan"


@implementation MyController

- (id) init
{
	self = [super init];
	
	return self;
}

- (void) dealloc
{
	[super dealloc];
}


- (IBAction) cProgramButtonPress:(id)sender
{
	NSLog(@"resource = %@", [[NSBundle mainBundle] pathForResource:@"a" ofType:@"out"]);
	NSString *newLinesString = [self runTaskWithPath:[[NSBundle mainBundle] pathForResource:@"a" ofType:@"out"] withArgs:[NSArray array]];
	NSLog(@"newLinesString = %@", newLinesString);
	[self showString:newLinesString];
}

- (IBAction) icalBuddyButtonPress:(id)sender
{
	NSString *newLinesString = [self 
								runTaskWithPath:@"/usr/local/bin/icalBuddy"
								withArgs:[NSArray arrayWithObjects:@"-f",@"-sc",@"eventsToday+10",nil]
								];
	[self showString:newLinesString];
}

- (IBAction) perlScriptButtonPress:(id)sender
{
	NSString *newLinesString = [self runTaskWithPath:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"pl"] withArgs:[NSArray array]];
	[self showString:newLinesString];
}

- (IBAction) oneCharPerlScriptButtonPress:(id)sender
{
	NSString *newLinesString = [self runTaskWithPath:[[NSBundle mainBundle] pathForResource:@"test-onechar" ofType:@"pl"] withArgs:[NSArray array]];
	[self showString:newLinesString];
}


- (void) showString:(NSString*)string
{
	[textView setBaseWritingDirection:NSWritingDirectionLeftToRight];
	
	// clean all attributes
	NSArray *attrs = [NSArray arrayWithObjects:
					  NSFontAttributeName,
					  NSParagraphStyleAttributeName,
					  NSForegroundColorAttributeName,
					  NSUnderlineStyleAttributeName,
					  NSSuperscriptAttributeName,
					  NSBackgroundColorAttributeName,
					  NSAttachmentAttributeName,
					  NSLigatureAttributeName,
					  NSBaselineOffsetAttributeName,
					  NSKernAttributeName,
					  NSLinkAttributeName,
					  NSStrokeWidthAttributeName,
					  NSStrokeColorAttributeName,
					  NSUnderlineColorAttributeName,
					  NSStrikethroughStyleAttributeName,
					  NSStrikethroughColorAttributeName,
					  NSShadowAttributeName,
					  NSObliquenessAttributeName,
					  NSExpansionAttributeName,
					  NSCursorAttributeName,
					  NSToolTipAttributeName,
					  NSMarkedClauseSegmentAttributeName,
					  nil
					  ];
	NSString *attr;
	NSRange fullRange = NSMakeRange(0, [[textView string] length]);
	for (attr in attrs)
	{
		[[textView textStorage] removeAttribute:attr range:fullRange];
	}
	
	
	ansiEscapeHelper = [[[ANSIEscapeHelper alloc] init] autorelease];
	
	// set colors & font to use to ansiEscapeHelper
	NSDictionary *colorPrefDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
										   [NSNumber numberWithInt:SGRCodeFgBlack], kANSIColorPrefKey_FgBlack,
										   [NSNumber numberWithInt:SGRCodeFgWhite], kANSIColorPrefKey_FgWhite,
										   [NSNumber numberWithInt:SGRCodeFgRed], kANSIColorPrefKey_FgRed,
										   [NSNumber numberWithInt:SGRCodeFgGreen], kANSIColorPrefKey_FgGreen,
										   [NSNumber numberWithInt:SGRCodeFgYellow], kANSIColorPrefKey_FgYellow,
										   [NSNumber numberWithInt:SGRCodeFgBlue], kANSIColorPrefKey_FgBlue,
										   [NSNumber numberWithInt:SGRCodeFgMagenta], kANSIColorPrefKey_FgMagenta,
										   [NSNumber numberWithInt:SGRCodeFgCyan], kANSIColorPrefKey_FgCyan,
										   [NSNumber numberWithInt:SGRCodeBgBlack], kANSIColorPrefKey_BgBlack,
										   [NSNumber numberWithInt:SGRCodeBgWhite], kANSIColorPrefKey_BgWhite,
										   [NSNumber numberWithInt:SGRCodeBgRed], kANSIColorPrefKey_BgRed,
										   [NSNumber numberWithInt:SGRCodeBgGreen], kANSIColorPrefKey_BgGreen,
										   [NSNumber numberWithInt:SGRCodeBgYellow], kANSIColorPrefKey_BgYellow,
										   [NSNumber numberWithInt:SGRCodeBgBlue], kANSIColorPrefKey_BgBlue,
										   [NSNumber numberWithInt:SGRCodeBgMagenta], kANSIColorPrefKey_BgMagenta,
										   [NSNumber numberWithInt:SGRCodeBgCyan], kANSIColorPrefKey_BgCyan,
										   nil];
	NSUInteger iColorPrefDefaultsKey;
	NSData *colorData;
	NSString *thisPrefName;
	for (iColorPrefDefaultsKey = 0; iColorPrefDefaultsKey < [[colorPrefDefaults allKeys] count]; iColorPrefDefaultsKey++)
	{
		thisPrefName = [[colorPrefDefaults allKeys] objectAtIndex:iColorPrefDefaultsKey];
		colorData = [[NSUserDefaults standardUserDefaults] dataForKey:thisPrefName];
		if (colorData != nil)
		{
			NSColor *thisColor = (NSColor *)[NSUnarchiver unarchiveObjectWithData:colorData];
			[[ansiEscapeHelper ansiColors] setObject:thisColor forKey:[colorPrefDefaults objectForKey:thisPrefName]];
		}
	}
	[ansiEscapeHelper setFont:[textView font]];
	
	if (string == nil)
		return;
	
	// get attributed string and display it
	NSMutableAttributedString *attrStr = [[[NSMutableAttributedString alloc] init] autorelease];
	[attrStr setAttributedString:[ansiEscapeHelper attributedStringWithANSIEscapedString:string]];
	
	/*
	 // test changing the attributed string programmatically after generating it
	 // but before changing it back to an ANSI-escaped string
	[attrStr
	 addAttributes:[NSDictionary
					dictionaryWithObject:(NSColor *)[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] dataForKey:kANSIColorPrefKey_FgMagenta]]
					forKey:NSForegroundColorAttributeName
					]
	 range:NSMakeRange(16, 4)
	];
	 */
	
	[[textView textStorage] setAttributedString:attrStr];
	
	NSString *ansiStr = [ansiEscapeHelper ansiEscapedStringWithAttributedString:attrStr];
	NSLog(@"\n%@", ansiStr);
}





- (NSString *) runTaskWithPath:(NSString *)path withArgs:(NSArray *)args
{
	NSPipe *pipe;
	pipe = [NSPipe pipe];
	
	NSTask *task;
	task = [[NSTask alloc] init];
	[task setLaunchPath: path];
	[task setArguments: args];
	[task setStandardOutput: pipe];
	
	NSFileHandle *file;
	file = [pipe fileHandleForReading];
	
	[task launch];
	
	NSData *data;
	data = [file readDataToEndOfFile];
	
	NSString *string;
	string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	
	[task release];
	
	return [string autorelease];
}




@end
