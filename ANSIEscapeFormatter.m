//
//  ANSIEscapeFormatter.m
//
//  Created by Ali Rantakari on 18.3.09.
//  Copyright 2009 Ali Rantakari. All rights reserved.
//  
// todo: add license!

/*
 todo:
 
 - add public properties for the different ANSI colors (separately for fg and bg colors)
 - add "test prefs window" for setting the ANSI colors
 - optimize. it would be nice if this was faster.
 - write & generate proper API documentation
 
 */



#import "ANSIEscapeFormatter.h"

// the CSI (Control Sequence Initiator) -- i.e. "escape sequence prefix".
// (add your own CSI:Miami joke here)
#define kANSIEscapeCSI			@"\033["

// default colors
#define kDefaultANSIColorFgBlack	[NSColor blackColor]
#define kDefaultANSIColorFgRed		[NSColor redColor]
#define kDefaultANSIColorFgGreen	[NSColor greenColor]
#define kDefaultANSIColorFgYellow	[NSColor yellowColor]
#define kDefaultANSIColorFgBlue		[NSColor blueColor]
#define kDefaultANSIColorFgMagenta	[NSColor magentaColor]
#define kDefaultANSIColorFgCyan		[NSColor cyanColor]
#define kDefaultANSIColorFgWhite	[NSColor whiteColor]

#define kDefaultANSIColorBgBlack	[NSColor blackColor]
#define kDefaultANSIColorBgRed		[NSColor redColor]
#define kDefaultANSIColorBgGreen	[NSColor greenColor]
#define kDefaultANSIColorBgYellow	[NSColor yellowColor]
#define kDefaultANSIColorBgBlue		[NSColor blueColor]
#define kDefaultANSIColorBgMagenta	[NSColor magentaColor]
#define kDefaultANSIColorBgCyan		[NSColor cyanColor]
#define kDefaultANSIColorBgWhite	[NSColor whiteColor]




@implementation ANSIEscapeFormatter

@synthesize font, ansiColors;

- (id) init
{
	self = [super init];
	
	// default font
	self.font = [NSFont systemFontOfSize:[NSFont systemFontSize]];
	
	self.ansiColors = [NSMutableDictionary dictionary];
	
	return self;
}



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
	NSString *cleanString = @"";
	
	// find all escape sequences from aString and put them in this array along with their
	// start locations within the "clean" version of aString (i.e. one without any
	// escape sequences)
	NSMutableArray *formatCodes = [NSMutableArray array];
	
	NSLog(@"==> collect all formatCodes");
	
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
			// and not just the Control Sequence Initiator (the "prefix") by finding the
			// final byte of the control sequence (one that has an ASCII decimal value
			// between 64 and 126.) at the same time, read all formatting codes from inside
			// this escape sequence (there may be several, separated by semicolons.)
			unsigned int code = 0;
			NSMutableArray *codes = [NSMutableArray array];
			unsigned int lengthAddition = 1;
			NSUInteger thisIndex;
			for (;;)
			{
				thisIndex = (thisEscapeSequenceRange.location+thisEscapeSequenceRange.length+lengthAddition-1);
				if (thisIndex >= aStringLength)
					break;
				
				int c = (int)[aString characterAtIndex:thisIndex];
				
				if ((48 <= c) && (c <= 57)) // 0-9
				{
					int digit = c-48;
					NSLog(@"====== %d", digit);
					code = (code == 0) ? digit : code*10+digit;
				}
				
				// ASCII decimal 109 is the SGR (Select Graphic Rendition) final byte
				// ("m"). this means that the code value we've just read specifies formatting
				// for the output; exactly what we're interested in.
				if (c == 109)
				{
					NSLog(@"====== m");
					[codes addObject:[NSNumber numberWithUnsignedInt:code]];
					break;
				}
				else if ((64 <= c) && (c <= 126)) // any other valid final byte
				{
					NSLog(@"====== end");
					break;
				}
				else if (c == 59) // semicolon (;) separates codes within the same sequence
				{
					NSLog(@"====== ;");
					[codes addObject:[NSNumber numberWithUnsignedInt:code]];
					code = 0;
				}
				
				lengthAddition++;
			}
			thisEscapeSequenceRange.length += lengthAddition;
			
			NSUInteger locationInCleanString = coveredLength+thisEscapeSequenceRange.location-searchRange.location;
			
			NSUInteger iCode;
			for (iCode = 0; iCode < [codes count]; iCode++)
			{
				NSLog(@"  >> found code %d at %d", [[codes objectAtIndex:iCode] unsignedIntValue], locationInCleanString);
				
				[formatCodes addObject:
				 [NSDictionary dictionaryWithObjectsAndKeys:
				  [codes objectAtIndex:iCode], @"code",
				  [NSNumber numberWithUnsignedInteger:locationInCleanString], @"location",
				  nil
				  ]
				 ];
			}
			
			NSUInteger thisCoveredLength = thisEscapeSequenceRange.location-searchRange.location;
			if (thisCoveredLength > 0)
				cleanString = [cleanString stringByAppendingString:[aString substringWithRange:NSMakeRange(searchRange.location, thisCoveredLength)]];
			
			coveredLength += thisCoveredLength;
			searchRange.location = thisEscapeSequenceRange.location+thisEscapeSequenceRange.length;
			searchRange.length = aStringLength-searchRange.location;
		}
	}
	while(thisEscapeSequenceRange.location != NSNotFound);
	
	if (searchRange.length > 0)
		cleanString = [cleanString stringByAppendingString:[aString substringWithRange:searchRange]];
	
	
	NSLog(@"==> go through all formatCodes");
	
	NSUInteger iCode;
	for (iCode = 0; iCode < [formatCodes count]; iCode++)
	{
		NSLog(@"--> %d of %d", iCode, [formatCodes count]-1);
		
		NSDictionary *thisCodeDict = [formatCodes objectAtIndex:iCode];
		unichar thisCode = [[thisCodeDict objectForKey:@"code"] unsignedIntValue];
		NSUInteger formattingRunStartLocation = [[thisCodeDict objectForKey:@"location"] unsignedIntegerValue];
		
		// the attributed string attribute name for the formatting run introduced
		// by this code
		NSString *thisAttributeName = nil;
		
		// the attributed string attribute value for this formatting run introduced
		// by this code
		NSObject *thisAttributeValue = nil;
		
		// set attribute name
		switch(thisCode)
		{
			case SGRCodeFgBlack:
			case SGRCodeFgRed:
			case SGRCodeFgGreen:
			case SGRCodeFgYellow:
			case SGRCodeFgBlue:
			case SGRCodeFgMagenta:
			case SGRCodeFgCyan:
			case SGRCodeFgWhite:
				thisAttributeName = NSForegroundColorAttributeName;
				break;
			case SGRCodeBgBlack:
			case SGRCodeBgRed:
			case SGRCodeBgGreen:
			case SGRCodeBgYellow:
			case SGRCodeBgBlue:
			case SGRCodeBgMagenta:
			case SGRCodeBgCyan:
			case SGRCodeBgWhite:
				thisAttributeName = NSBackgroundColorAttributeName;
				break;
			case SGRCodeIntensityBold:
			case SGRCodeIntensityNormal:
				thisAttributeName = NSFontAttributeName;
				break;
			case SGRCodeUnderlineSingle:
			case SGRCodeUnderlineDouble:
				thisAttributeName = NSUnderlineStyleAttributeName;
				break;
			default:
				continue;
				break;
		}
		
		// set attribute value
		switch(thisCode)
		{
			case SGRCodeBgBlack:
			case SGRCodeFgBlack:
			case SGRCodeBgRed:
			case SGRCodeFgRed:
			case SGRCodeBgGreen:
			case SGRCodeFgGreen:
			case SGRCodeBgYellow:
			case SGRCodeFgYellow:
			case SGRCodeBgBlue:
			case SGRCodeFgBlue:
			case SGRCodeBgMagenta:
			case SGRCodeFgMagenta:
			case SGRCodeBgCyan:
			case SGRCodeFgCyan:
			case SGRCodeBgWhite:
			case SGRCodeFgWhite:
				thisAttributeValue = [self colorForSGRCode:thisCode];
				break;
			case SGRCodeIntensityBold:
				{
				NSFont *boldFont = [[NSFontManager sharedFontManager] convertFont:self.font toHaveTrait:NSBoldFontMask];
				thisAttributeValue = boldFont;
				}
				break;
			case SGRCodeIntensityNormal:
				{
				NSFont *unboldFont = [[NSFontManager sharedFontManager] convertFont:self.font toHaveTrait:NSUnboldFontMask];
				thisAttributeValue = unboldFont;
				}
				break;
			case SGRCodeUnderlineSingle:
				thisAttributeValue = [NSNumber numberWithInteger:NSUnderlineStyleSingle];
				break;
			case SGRCodeUnderlineDouble:
				thisAttributeValue = [NSNumber numberWithInteger:NSUnderlineStyleDouble];
				break;
		}
		
		
		
		
		NSLog(@"  find end sequence...");
		
		// find the next sequence that specifies the end of this formatting run
		NSInteger formattingRunEndLocation = -1;
		if (iCode < ([formatCodes count]-1))
		{
			NSUInteger iEndCode;
			NSDictionary *thisEndCodeCandidateDict;
			unichar thisEndCodeCandidate;
			for (iEndCode = iCode+1; iEndCode < [formatCodes count]; iEndCode++)
			{
				thisEndCodeCandidateDict = [formatCodes objectAtIndex:iEndCode];
				thisEndCodeCandidate = [[thisEndCodeCandidateDict objectForKey:@"code"] unsignedIntValue];
				
				if ([self sgrCode:thisEndCodeCandidate endsFormattingIntroducedByCode:thisCode])
				{
					formattingRunEndLocation = [[thisEndCodeCandidateDict objectForKey:@"location"] unsignedIntegerValue];
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
	
	NSLog(@"setting clean string...");
	
	*aCleanString = cleanString;
	
	NSLog(@"returning.");
	
	return attrsAndRanges;
}





- (BOOL) sgrCode:(enum sgrCode)endCode endsFormattingIntroducedByCode:(enum sgrCode)startCode
{
	switch(startCode)
	{
		case SGRCodeFgBlack:
		case SGRCodeFgRed:
		case SGRCodeFgGreen:
		case SGRCodeFgYellow:
		case SGRCodeFgBlue:
		case SGRCodeFgMagenta:
		case SGRCodeFgCyan:
		case SGRCodeFgWhite:
			return (endCode == SGRCodeAllReset || endCode == SGRCodeFgReset || 
					endCode == SGRCodeFgBlack || endCode == SGRCodeFgRed || 
					endCode == SGRCodeFgGreen || endCode == SGRCodeFgYellow || 
					endCode == SGRCodeFgBlue || endCode == SGRCodeFgMagenta || 
					endCode == SGRCodeFgCyan || endCode == SGRCodeFgWhite);
			break;
		case SGRCodeBgBlack:
		case SGRCodeBgRed:
		case SGRCodeBgGreen:
		case SGRCodeBgYellow:
		case SGRCodeBgBlue:
		case SGRCodeBgMagenta:
		case SGRCodeBgCyan:
		case SGRCodeBgWhite:
			return (endCode == SGRCodeAllReset || endCode == SGRCodeBgReset || 
					endCode == SGRCodeBgBlack || endCode == SGRCodeBgRed || 
					endCode == SGRCodeBgGreen || endCode == SGRCodeBgYellow || 
					endCode == SGRCodeBgBlue || endCode == SGRCodeBgMagenta || 
					endCode == SGRCodeBgCyan || endCode == SGRCodeBgWhite);
			break;
		case SGRCodeIntensityBold:
		case SGRCodeIntensityNormal:
			return (endCode == SGRCodeAllReset || endCode == SGRCodeIntensityNormal || 
					endCode == SGRCodeIntensityBold || endCode == SGRCodeIntensityFaint);
			break;
		case SGRCodeUnderlineSingle:
		case SGRCodeUnderlineDouble:
			return (endCode == SGRCodeAllReset || endCode == SGRCodeUnderlineNone || 
					endCode == SGRCodeUnderlineSingle || endCode == SGRCodeUnderlineDouble);
			break;
		default:
			return NO;
			break;
	}
	
	return NO;
}




- (NSColor*) colorForSGRCode:(enum sgrCode)code
{
	NSColor *preferredColor = [self.ansiColors objectForKey:[NSNumber numberWithInt:code]];
	if (preferredColor != nil)
		return preferredColor;
	
	switch(code)
	{
		case SGRCodeFgBlack:
			return kDefaultANSIColorFgBlack;
			break;
		case SGRCodeFgRed:
			return kDefaultANSIColorFgRed;
			break;
		case SGRCodeFgGreen:
			return kDefaultANSIColorFgGreen;
			break;
		case SGRCodeFgYellow:
			return kDefaultANSIColorFgYellow;
			break;
		case SGRCodeFgBlue:
			return kDefaultANSIColorFgBlue;
			break;
		case SGRCodeFgMagenta:
			return kDefaultANSIColorFgMagenta;
			break;
		case SGRCodeFgCyan:
			return kDefaultANSIColorFgCyan;
			break;
		case SGRCodeFgWhite:
			return kDefaultANSIColorFgWhite;
			break;
		case SGRCodeBgBlack:
			return kDefaultANSIColorBgBlack;
			break;
		case SGRCodeBgRed:
			return kDefaultANSIColorBgRed;
			break;
		case SGRCodeBgGreen:
			return kDefaultANSIColorBgGreen;
			break;
		case SGRCodeBgYellow:
			return kDefaultANSIColorBgYellow;
			break;
		case SGRCodeBgBlue:
			return kDefaultANSIColorBgBlue;
			break;
		case SGRCodeBgMagenta:
			return kDefaultANSIColorBgMagenta;
			break;
		case SGRCodeBgCyan:
			return kDefaultANSIColorBgCyan;
			break;
		case SGRCodeBgWhite:
			return kDefaultANSIColorBgWhite;
			break;
	}
	
	return kDefaultANSIColorFgBlack;
}



@end
