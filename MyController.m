#import "MyController.h"


/*
 todo:
 
 - modularize:
	- write helper method rangeOfOneOfStrings:(NSArray*)strings inString:(NSString*)subject options: range:
	- use the above to clean the thing up a bit
 - make finding of the endRange more intelligent:
	- don't just get the next escape sequence; must get the
	  next escape sequence that actually ends the formatting
	  run that the start sequence starts (read the specs so
	  that these become perfectly clear to you!)
 - make sure that unsupported escape sequences are handled gracefully (i.e. we don't want to crash or hang)
 - add support for underline & italic
 
 */

@implementation MyController

- (id) init
{
	self = [super init];
	
	return self;
}


- (IBAction)buttonPress:(id)sender
{
	//NSString *newLinesString = [self runTaskWithPath:@"/usr/local/bin/icalBuddy" withArgs:[NSArray arrayWithObjects:@"-f",@"-sc",@"uncompletedTasks",nil]];
	NSString *newLinesString = [self runTaskWithPath:[[NSBundle mainBundle] pathForResource:@"a" ofType:@"out"] withArgs:[NSArray array]];
	
	
	NSString *cleanNewLinesString = nil;
	
	ansiFormatter = [[[ANSIEscapeFormatter alloc] init] autorelease];
	NSArray *formatsAndRanges = [ansiFormatter attributesForString:newLinesString cleanString:&cleanNewLinesString];
	
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
