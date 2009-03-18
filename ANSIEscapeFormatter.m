//
//  ANSIEscapeFormatter.m
//  AnsiColorsTest
//
//  Created by Ali Rantakari on 18.3.09.
//  Copyright 2009 Ali Rantakari. All rights reserved.
//

#import "ANSIEscapeFormatter.h"

#define kANSIEscapeCSI			@"\033["

#define kControlSequenceMaxLengthAfterCSI 3

#define kANSIEscapeAllReset		@"\033[0m"

#define kANSIEscapeIntensityBold	@"\033[01m"
#define kANSIEscapeIntensityReset	@"\033[22m"

#define kANSIEscapeIntensityEndSequences [NSArray arrayWithObjects:kANSIEscapeIntensityReset, kANSIEscapeAllReset, nil]

#define kANSIEscapeFgRed 		@"\033[31m"
#define kANSIEscapeFgGreen		@"\033[32m"
#define kANSIEscapeFgYellow 	@"\033[33m"
#define kANSIEscapeFgBlue		@"\033[34m"
#define kANSIEscapeFgMagenta 	@"\033[35m"
#define kANSIEscapeFgCyan		@"\033[36m"
#define kANSIEscapeFgWhite		@"\033[37m"
#define kANSIEscapeFgReset		@"\033[39m"

#define kANSIEscapeFgEndSequences [NSArray arrayWithObjects:\
										kANSIEscapeFgRed, kANSIEscapeFgBlue, kANSIEscapeFgGreen, kANSIEscapeFgYellow,\
										kANSIEscapeFgCyan, kANSIEscapeFgMagenta, kANSIEscapeFgWhite,\
										kANSIEscapeFgReset, kANSIEscapeAllReset,\
										nil\
									]

#define kANSIEscapeBgRed 		@"\033[41m"
#define kANSIEscapeBgGreen 		@"\033[42m"
#define kANSIEscapeBgYellow 	@"\033[43m"
#define kANSIEscapeBgBlue 		@"\033[44m"
#define kANSIEscapeBgMagenta 	@"\033[45m"
#define kANSIEscapeBgCyan		@"\033[46m"
#define kANSIEscapeBgWhite		@"\033[47m"
#define kANSIEscapeBgReset		@"\033[49m"

#define kANSIEscapeBgEndSequences [NSArray arrayWithObjects:\
										kANSIEscapeBgRed, kANSIEscapeBgBlue, kANSIEscapeBgGreen, kANSIEscapeBgYellow,\
										kANSIEscapeBgCyan, kANSIEscapeBgMagenta, kANSIEscapeBgWhite,\
										kANSIEscapeBgReset, kANSIEscapeAllReset,\
										nil]

#define kAllANSIEscapeSequences [NSArray arrayWithObjects:\
									kANSIEscapeIntensityBold,\
									kANSIEscapeFgRed, kANSIEscapeFgGreen, kANSIEscapeFgYellow, kANSIEscapeFgBlue,\
									kANSIEscapeFgMagenta, kANSIEscapeFgCyan, kANSIEscapeFgWhite,\
									kANSIEscapeBgRed, kANSIEscapeBgGreen, kANSIEscapeBgYellow, kANSIEscapeBgBlue,\
									kANSIEscapeBgMagenta, kANSIEscapeBgCyan, kANSIEscapeBgWhite,\
									kANSIEscapeAllReset, kANSIEscapeBgReset, kANSIEscapeFgReset,\
									nil]


@implementation ANSIEscapeFormatter



- (NSArray*) attributesForString:(NSString*)aString cleanString:(NSString**)aCleanString
{
	if (aString == nil)
		return nil;
	if ([aString length] <= [kANSIEscapeCSI length])
	{
		*aCleanString = [NSString stringWithString:aString];
		return [NSArray array];
	}
	
	NSLog(@"STARTING");
	NSLog(@"========================");
	
	NSMutableArray *attrsAndRanges = [NSMutableArray array];
	
	// find all escape sequences from aString and put them in this array along with their
	// start locations within the "clean" version of aString (i.e. one without any
	// escape sequences)
	NSMutableArray *escapeSequences = [NSMutableArray array];
	
	NSLog(@"==> collect all escapeSequences");
	
	NSUInteger aStringLength = [aString length];
	NSUInteger coveredLength = 0;
	NSRange searchRange = NSMakeRange(0,aStringLength);
	NSRange thisEscapeSequenceRange;
	do
	{
		thisEscapeSequenceRange = [aString rangeOfString:kANSIEscapeCSI options:NSLiteralSearch range:searchRange];
		if (thisEscapeSequenceRange.location != NSNotFound)
		{
			// adjust range's length so that it encompasses the whole ANSI escape sequence
			// and not just the Control Sequence Initiator (the "prefix")
			unsigned int lengthAddition = 0;
			unsigned int maxLengthAddition = kControlSequenceMaxLengthAfterCSI;
			for (lengthAddition = 0; lengthAddition <= maxLengthAddition; lengthAddition++)
			{
				if ([[aString substringWithRange:NSMakeRange(thisEscapeSequenceRange.location+thisEscapeSequenceRange.length+lengthAddition-1, 1)] isEqualToString:@"m"])
					break;
			}
			thisEscapeSequenceRange.length += lengthAddition;
			
			NSString *thisEscapeSequence = [aString substringWithRange:thisEscapeSequenceRange];
			NSUInteger thisEscapeSequenceLocation = coveredLength+thisEscapeSequenceRange.location-searchRange.location;
			
			NSLog(@"  >> found '%@' at %d", thisEscapeSequence, thisEscapeSequenceLocation);
			
			[escapeSequences addObject:
			 [NSDictionary dictionaryWithObjectsAndKeys:
			  thisEscapeSequence, @"sequence",
			  [NSNumber numberWithUnsignedInteger:thisEscapeSequenceLocation], @"location",
			  nil
			  ]
			 ];
			
			coveredLength += thisEscapeSequenceRange.location-searchRange.location;
			searchRange.location = thisEscapeSequenceRange.location+thisEscapeSequenceRange.length;
			searchRange.length = aStringLength-searchRange.location;
		}
	}
	while(thisEscapeSequenceRange.location != NSNotFound);
	
	NSLog(@"==> go through all escapeSequences");
	
	NSUInteger iSequence;
	for (iSequence = 0; iSequence < [escapeSequences count]; iSequence++)
	{
		NSLog(@"--> %d of %d", iSequence, [escapeSequences count]-1);
		
		NSDictionary *thisSequenceDict = [escapeSequences objectAtIndex:iSequence];
		NSString *thisSequence = [thisSequenceDict objectForKey:@"sequence"];
		NSUInteger formattingRunStartLocation = [[thisSequenceDict objectForKey:@"location"] unsignedIntegerValue];
		
		// the attributed string attribute name for the formatting run introduced
		// by this sequence
		NSString *thisAttributeName = NSForegroundColorAttributeName;
		
		// the attributed string attribute value for this formatting run introduced
		// by this sequence
		NSObject *thisAttributeValue = nil;
		
		// list of all the sequences the occurrence of which would specify the end of
		// the formatting run introduced by this sequence:
		NSArray *thisEndSequences = kANSIEscapeFgEndSequences;
		
		if ([thisSequence isEqualToString:kANSIEscapeFgRed])
		{
			NSLog(@"  >> red at %d", formattingRunStartLocation);
			thisAttributeValue = [NSColor redColor];
		}
		else if ([thisSequence isEqualToString:kANSIEscapeFgBlue])
		{
			NSLog(@"  >> blue at %d", formattingRunStartLocation);
			thisAttributeValue = [NSColor blueColor];
		}
		else if ([thisSequence isEqualToString:kANSIEscapeFgGreen])
		{
			NSLog(@"  >> green at %d", formattingRunStartLocation);
			thisAttributeValue = [NSColor greenColor];
		}
		else if ([thisSequence isEqualToString:kANSIEscapeFgYellow])
		{
			NSLog(@"  >> yellow at %d", formattingRunStartLocation);
			thisAttributeValue = [NSColor yellowColor];
		}
		else if ([thisSequence isEqualToString:kANSIEscapeFgCyan])
		{
			NSLog(@"  >> cyan at %d", formattingRunStartLocation);
			thisAttributeValue = [NSColor cyanColor];
		}
		else if ([thisSequence isEqualToString:kANSIEscapeFgMagenta])
		{
			NSLog(@"  >> magenta at %d", formattingRunStartLocation);
			thisAttributeValue = [NSColor magentaColor];
		}
		else if ([thisSequence isEqualToString:kANSIEscapeFgWhite])
		{
			NSLog(@"  >> white at %d", formattingRunStartLocation);
			thisAttributeValue = [NSColor whiteColor];
		}
		else if ([thisSequence isEqualToString:kANSIEscapeBgRed])
		{
			NSLog(@"  >> redBg at %d", formattingRunStartLocation);
			thisAttributeName = NSBackgroundColorAttributeName;
			thisAttributeValue = [NSColor redColor];
			thisEndSequences = kANSIEscapeBgEndSequences;
		}
		else if ([thisSequence isEqualToString:kANSIEscapeBgBlue])
		{
			NSLog(@"  >> blueBg at %d", formattingRunStartLocation);
			thisAttributeName = NSBackgroundColorAttributeName;
			thisAttributeValue = [NSColor blueColor];
			thisEndSequences = kANSIEscapeBgEndSequences;
		}
		else if ([thisSequence isEqualToString:kANSIEscapeBgGreen])
		{
			NSLog(@"  >> greenBg at %d", formattingRunStartLocation);
			thisAttributeName = NSBackgroundColorAttributeName;
			thisAttributeValue = [NSColor greenColor];
			thisEndSequences = kANSIEscapeBgEndSequences;
		}
		else if ([thisSequence isEqualToString:kANSIEscapeBgYellow])
		{
			NSLog(@"  >> yellowBg at %d", formattingRunStartLocation);
			thisAttributeName = NSBackgroundColorAttributeName;
			thisAttributeValue = [NSColor yellowColor];
			thisEndSequences = kANSIEscapeBgEndSequences;
		}
		else if ([thisSequence isEqualToString:kANSIEscapeBgCyan])
		{
			NSLog(@"  >> cyanBg at %d", formattingRunStartLocation);
			thisAttributeName = NSBackgroundColorAttributeName;
			thisAttributeValue = [NSColor cyanColor];
			thisEndSequences = kANSIEscapeBgEndSequences;
		}
		else if ([thisSequence isEqualToString:kANSIEscapeBgMagenta])
		{
			NSLog(@"  >> magentaBg at %d", formattingRunStartLocation);
			thisAttributeName = NSBackgroundColorAttributeName;
			thisAttributeValue = [NSColor magentaColor];
			thisEndSequences = kANSIEscapeBgEndSequences;
		}
		else if ([thisSequence isEqualToString:kANSIEscapeBgWhite])
		{
			NSLog(@"  >> whiteBg at %d", formattingRunStartLocation);
			thisAttributeName = NSBackgroundColorAttributeName;
			thisAttributeValue = [NSColor whiteColor];
			thisEndSequences = kANSIEscapeBgEndSequences;
		}
		else if ([thisSequence isEqualToString:kANSIEscapeIntensityBold])
		{
			NSLog(@"  >> bold at %d", formattingRunStartLocation);
			thisAttributeName = NSFontAttributeName;
			NSFont *boldFont = [NSFont systemFontOfSize:[NSFont systemFontSize]];
			boldFont = [[NSFontManager sharedFontManager] convertFont:boldFont toHaveTrait:NSBoldFontMask];
			thisAttributeValue = boldFont;
			thisEndSequences = kANSIEscapeIntensityEndSequences;
		}
		else
		{
			if ([thisSequence isEqualToString:kANSIEscapeAllReset])
				NSLog(@"  >> reset at %d", formattingRunStartLocation);
			else
				NSLog(@"  >> NO FORMAT at %d", formattingRunStartLocation);
			
			// this ANSI escape sequence is either unrecognized or just
			// doesn't begin any formatting runs, so we skip it
			continue;
		}
		
		NSLog(@"  find end sequence...");
		
		// find the next sequence that specifies the end of this formatting run
		NSInteger formattingRunEndLocation = -1;
		if (iSequence < ([escapeSequences count]-1))
		{
			NSUInteger iEndSequence;
			NSDictionary *thisEndSequenceDict;
			for (iEndSequence = iSequence+1; iEndSequence < [escapeSequences count]; iEndSequence++)
			{
				thisEndSequenceDict = [escapeSequences objectAtIndex:iEndSequence];
				if ([thisEndSequences containsObject:[thisEndSequenceDict objectForKey:@"sequence"]])
				{
					formattingRunEndLocation = [[thisEndSequenceDict objectForKey:@"location"] unsignedIntegerValue];
					break;
				}
			}
		}
		if (formattingRunEndLocation == -1)
			formattingRunEndLocation = aStringLength;
		
		NSLog(@"  end location: %d (string length %d)", formattingRunEndLocation, aStringLength);
		
		[attrsAndRanges addObject:
		 [NSDictionary dictionaryWithObjectsAndKeys:
		  [NSValue valueWithRange:NSMakeRange(formattingRunStartLocation, (formattingRunEndLocation-formattingRunStartLocation))], @"range",
		  thisAttributeName, @"attributeName",
		  thisAttributeValue, @"attributeValue",
		  nil
		 ]
		];
	}
	
	NSLog(@"making clean string...");
	
	// todo: build this string in the first do-while loop above -- it'll be faster
	*aCleanString = [self stripEscapeSequencesFromString:aString];
	
	NSLog(@"returning.");
	
	return attrsAndRanges;
}






- (NSRange) rangeOfOneOfStrings:(NSArray*)aStrings
					   inString:(NSString*)aSubject
						options:(NSStringCompareOptions)aOptions
						  range:(NSRange)aRange
{
	NSRange firstRange = NSMakeRange(NSNotFound, 0);
	
	if (aStrings == nil || aSubject == nil || aRange.length == 0)
		return firstRange;
	
	NSRange thisRange;
	NSUInteger i;
	for (i = 0; i < [aStrings count]; i++)
	{
		thisRange = [aSubject rangeOfString:[aStrings objectAtIndex:i] options:aOptions range:aRange];
		if (thisRange.location != NSNotFound && (firstRange.location == NSNotFound || thisRange.location < firstRange.location))
		{
			firstRange.location = thisRange.location;
			firstRange.length = thisRange.length;
		}
	}
	return firstRange;
}


- (NSString*) stripEscapeSequencesFromString:(NSString*)aString
{
	if (aString == nil)
		return nil;
	if ([aString length] == 0)
		return aString;
	
	NSString *cleanString = [NSString stringWithString:aString];
	
	NSArray *substringsToStrip = kAllANSIEscapeSequences;
	NSUInteger i;
	for (i = 0; i < [substringsToStrip count]; i++)
	{
		cleanString = [cleanString stringByReplacingOccurrencesOfString:[substringsToStrip objectAtIndex:i] withString:@""];
	}
	return cleanString;
}


@end
