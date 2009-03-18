#import "MyController.h"



@implementation MyController

- (id) init
{
	self = [super init];
	
	return self;
}


- (IBAction) cProgramButtonPress:(id)sender
{
	NSString *newLinesString = [self runTaskWithPath:[[NSBundle mainBundle] pathForResource:@"a" ofType:@"out"] withArgs:[NSArray array]];
	[self showString:newLinesString];
}

- (IBAction) icalBuddyButtonPress:(id)sender
{
	NSString *newLinesString = [self runTaskWithPath:@"/usr/local/bin/icalBuddy" withArgs:[NSArray arrayWithObjects:@"-f",@"-sc",@"uncompletedTasks",nil]];
	[self showString:newLinesString];
}

- (IBAction) perlScriptButtonPress:(id)sender
{
	NSString *newLinesString = [self runTaskWithPath:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"pl"] withArgs:[NSArray array]];
	[self showString:newLinesString];
}


- (void) showString:(NSString*)string
{
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
	
	NSString *cleanNewLinesString = nil;
	
	ansiFormatter = [[[ANSIEscapeFormatter alloc] init] autorelease];
	[ansiFormatter setFont:[textView font]];
	NSArray *formatsAndRanges = [ansiFormatter attributesForString:string cleanString:&cleanNewLinesString];
	
	NSLog(@"======");
	NSLog(@"set clean string to textView");
	
	[textView setString:cleanNewLinesString];
	
	NSLog(@"set attributes to textStorage");
	
	NSDictionary *thisFormatRange;
	unsigned int iFormatRange;
	for (iFormatRange = 0; iFormatRange < [formatsAndRanges count]; iFormatRange++)
	{
		thisFormatRange = [formatsAndRanges objectAtIndex:iFormatRange];
		[[textView textStorage]
		 addAttribute:[thisFormatRange objectForKey:@"attributeName"]
		 value:[thisFormatRange objectForKey:@"attributeValue"]
		 range:[[thisFormatRange objectForKey:@"range"] rangeValue]
		 ];
	}
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
	
	return string;
}




@end
