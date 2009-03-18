#import "MyController.h"

#define kANSIEscapePrefix	@"\033["

#define kANSIEscapeReset 	@"\033[0m"
#define kANSIEscapeBold 	@"\033[01m"

#define kANSIEscapeRed 		@"\033[31m"
#define kANSIEscapeGreen 	@"\033[32m"
#define kANSIEscapeYellow 	@"\033[33m"
#define kANSIEscapeBlue 	@"\033[34m"
#define kANSIEscapeMagenta 	@"\033[35m"
#define kANSIEscapeCyan		@"\033[36m"


@implementation MyController

- (IBAction)buttonPress:(id)sender
{
	NSString *newLinesString = [self runTaskWithPath:@"/usr/local/bin/icalBuddy" withArgs:[NSArray arrayWithObjects:@"-f",@"-sc",@"uncompletedTasks",nil]];
	NSString *newLinesStringMod = @"";
	
	// read ANSI formatting control sequences from the string and create attribute ranges
	// for those so that we can show those colors in the output
	NSMutableArray *formatsAndRanges = [NSMutableArray array];
	
	NSRange searchRange = NSMakeRange(0,[newLinesString length]);
	NSRange startRange; // range of the "start" ANSI escape sequence (the one that starts formatting for subsequent characters)
	NSRange endRange; // range of the next "end" ANSI escape sequence (the one that stops the previous formatting)
	NSRange lastEndRange = NSMakeRange(0, 0);
	do
	{
		startRange = [newLinesString rangeOfString:kANSIEscapePrefix options:NSLiteralSearch range:searchRange];
		if (startRange.location != NSNotFound)
		{
			// adjust start range's length so that it encompasses the whole ANSI escape sequence
			// and not just the prefix
			unsigned int startLengthAddition = 0;
			unsigned int maxStartLengthAddition = 5;
			for (startLengthAddition = 0; startLengthAddition <= maxStartLengthAddition; startLengthAddition++)
			{
				if ([[newLinesString substringWithRange:NSMakeRange(startRange.location+startRange.length+startLengthAddition-1, 1)] isEqualToString:@"m"])
					break;
			}
			startRange.length += startLengthAddition;
			
			NSLog(@"---------");
			NSLog(@"");
			
			NSString *startSequence = [newLinesString substringWithRange:startRange];
			NSLog(@"startSequence = '%@'", startSequence);
			NSString *thisAttributeName = NSForegroundColorAttributeName;
			NSObject *thisAttributeValue = nil;
			if ([startSequence isEqualToString:kANSIEscapeRed])
			{
				NSLog(@"  >> red");
				thisAttributeValue = [NSColor redColor];
			}
			else if ([startSequence isEqualToString:kANSIEscapeBlue])
			{
				NSLog(@"  >> blue");
				thisAttributeValue = [NSColor blueColor];
			}
			else if ([startSequence isEqualToString:kANSIEscapeGreen])
			{
				NSLog(@"  >> green");
				thisAttributeValue = [NSColor greenColor];
			}
			else if ([startSequence isEqualToString:kANSIEscapeYellow])
			{
				NSLog(@"  >> yellow");
				thisAttributeValue = [NSColor yellowColor];
			}
			else if ([startSequence isEqualToString:kANSIEscapeCyan])
			{
				NSLog(@"  >> cyan");
				thisAttributeValue = [NSColor cyanColor];
			}
			else if ([startSequence isEqualToString:kANSIEscapeMagenta])
			{
				NSLog(@"  >> magenta");
				thisAttributeValue = [NSColor magentaColor];
			}
			else if ([startSequence isEqualToString:kANSIEscapeBold])
			{
				NSLog(@"  >> bold");
				thisAttributeName = NSFontAttributeName;
				NSFont *boldFont = [NSFont fontWithName:[[textView font] fontName] size:[[textView font] pointSize]];
				boldFont = [[NSFontManager sharedFontManager] convertFont:boldFont toHaveTrait:NSBoldFontMask];
				thisAttributeValue = boldFont;
			}
			else
			{
				NSLog(@"  >> NO FORMAT");
				thisAttributeName = nil;
			}
			
			// format specifier found, now let's try to find the end of this "formatting run" by
			// searching for the next ANSI escape formatting specifier "prefix". if this is not
			// found, let's use the end of the whole string.
			endRange = [newLinesString rangeOfString:kANSIEscapePrefix options:NSLiteralSearch range:NSMakeRange((startRange.location+startRange.length), ([newLinesString length]-(startRange.location+startRange.length)))];
			if (endRange.location == NSNotFound)
				endRange = NSMakeRange([newLinesString length], 0);
			else
			{
				// adjust end range's length so that it encompasses the whole ANSI escape sequence
				// and not just the prefix
				unsigned int lengthAddition = 0;
				unsigned int maxLengthAddition = 5;
				for (lengthAddition = 0; lengthAddition <= maxLengthAddition; lengthAddition++)
				{
					if ([[newLinesString substringWithRange:NSMakeRange(endRange.location+endRange.length+lengthAddition-1, 1)] isEqualToString:@"m"])
						break;
				}
				endRange.length += lengthAddition;
			}
			
			NSString *endOfLastEndRangeToStartOfThisStartRange = [newLinesString substringWithRange:NSMakeRange((lastEndRange.location+lastEndRange.length), (startRange.location-(lastEndRange.location+lastEndRange.length)))];
			NSString *thisRangeStr = [newLinesString substringWithRange:NSMakeRange((startRange.location+startRange.length), (endRange.location-(startRange.location+startRange.length)))];
			
			NSRange thisRange = NSMakeRange(([newLinesStringMod length]+[endOfLastEndRangeToStartOfThisStartRange length]), (endRange.location-(startRange.location+startRange.length)));
			if (thisAttributeName != nil)
			{
				NSDictionary *thisNewFormatRange = [NSDictionary dictionaryWithObjectsAndKeys:
													[NSValue valueWithRange:thisRange], @"range",
													thisAttributeName, @"attributeName",
													thisAttributeValue, @"attributeValue",
													nil];
				[formatsAndRanges addObject:thisNewFormatRange];
			}
			
			NSLog(@"Adding:\n   '%@'\n   '%@'",
				  [endOfLastEndRangeToStartOfThisStartRange stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]],
				  [thisRangeStr stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]
			);
			newLinesStringMod = [newLinesStringMod stringByAppendingString:endOfLastEndRangeToStartOfThisStartRange];
			newLinesStringMod = [newLinesStringMod stringByAppendingString:thisRangeStr];
			
			searchRange.location = (endRange.location+endRange.length);
			searchRange.length = ([newLinesString length]-searchRange.location);
			lastEndRange = endRange;
		}
	}
	while(startRange.location != NSNotFound && (searchRange.location+searchRange.length <= [newLinesString length]));
	
	[textView setString:newLinesStringMod];
	
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
