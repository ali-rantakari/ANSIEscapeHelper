//
//  ANSIEscapeFormatter.m
//
//  Created by Ali Rantakari on 18.3.09.
//  Copyright 2009 Ali Rantakari. All rights reserved.
//  
//  Description:
//  ---------------
//  Contains helper methods for dealing with strings
//  that contain ANSI escape sequences for formatting
//  (like colors etc.) Not optimized for speed or
//  anything but should be ok enough for most
//  purposes.
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

// macro definitions for different SGR (Select Graphic Rendition)
// control codes and for functions used to check whether the
// occurrence of a given code would end a specific kind of formatting
// run (e.g. foreground color, or underlining.)

#define kSGRCodeAllReset		0

#define kSGRCodeIntensityBold	1
#define kSGRCodeIntensityFaint	2
#define kSGRCodeIntensityNormal	22

#define kCodeEndsIntensityFormatting(x)		(x == kSGRCodeAllReset || x == kSGRCodeIntensityNormal || \
											 x == kSGRCodeIntensityBold || x == kSGRCodeIntensityFaint)

#define kSGRCodeItalicOn		3

#define kCodeEndsItalicFormatting(x)		(x == kSGRCodeAllReset || x == kSGRCodeItalicOn)


#define kSGRCodeUnderlineSingle	4
#define kSGRCodeUnderlineDouble	21
#define kSGRCodeUnderlineNone	24

#define kCodeEndsUnderlineFormatting(x)		(x == kSGRCodeAllReset || x == kSGRCodeUnderlineNone || \
											 x == kSGRCodeUnderlineSingle || x == kSGRCodeUnderlineDouble)


#define kSGRCodeFgBlack		30
#define kSGRCodeFgRed		31
#define kSGRCodeFgGreen		32
#define kSGRCodeFgYellow	33
#define kSGRCodeFgBlue		34
#define kSGRCodeFgMagenta	35
#define kSGRCodeFgCyan		36
#define kSGRCodeFgWhite		37
#define kSGRCodeFgReset		39

#define kCodeEndsFgFormatting(x)	(x == kSGRCodeAllReset || x == kSGRCodeFgReset || \
									 x == kSGRCodeFgBlack || x == kSGRCodeFgRed || \
									 x == kSGRCodeFgGreen || x == kSGRCodeFgYellow || \
									 x == kSGRCodeFgBlue || x == kSGRCodeFgMagenta || \
									 x == kSGRCodeFgCyan || x == kSGRCodeFgWhite)


#define kSGRCodeBgBlack		40
#define kSGRCodeBgRed		41
#define kSGRCodeBgGreen		42
#define kSGRCodeBgYellow	43
#define kSGRCodeBgBlue		44
#define kSGRCodeBgMagenta	45
#define kSGRCodeBgCyan		46
#define kSGRCodeBgWhite		47
#define kSGRCodeBgReset		49

#define kCodeEndsBgFormatting(x)	(x == kSGRCodeAllReset || x == kSGRCodeBgReset || \
									 x == kSGRCodeBgBlack || x == kSGRCodeBgRed || \
									 x == kSGRCodeBgGreen || x == kSGRCodeBgYellow || \
									 x == kSGRCodeBgBlue || x == kSGRCodeBgMagenta || \
									 x == kSGRCodeBgCyan || x == kSGRCodeBgWhite)



@implementation ANSIEscapeFormatter

@synthesize font;

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
			case kSGRCodeFgBlack:
			case kSGRCodeFgRed:
			case kSGRCodeFgGreen:
			case kSGRCodeFgYellow:
			case kSGRCodeFgBlue:
			case kSGRCodeFgMagenta:
			case kSGRCodeFgCyan:
			case kSGRCodeFgWhite:
				thisAttributeName = NSForegroundColorAttributeName;
				break;
			case kSGRCodeBgBlack:
			case kSGRCodeBgRed:
			case kSGRCodeBgGreen:
			case kSGRCodeBgYellow:
			case kSGRCodeBgBlue:
			case kSGRCodeBgMagenta:
			case kSGRCodeBgCyan:
			case kSGRCodeBgWhite:
				thisAttributeName = NSBackgroundColorAttributeName;
				break;
			case kSGRCodeIntensityBold:
			case kSGRCodeIntensityNormal:
				thisAttributeName = NSFontAttributeName;
				break;
			case kSGRCodeUnderlineSingle:
			case kSGRCodeUnderlineDouble:
				thisAttributeName = NSUnderlineStyleAttributeName;
				break;
			default:
				continue;
				break;
		}
		
		// set attribute value
		switch(thisCode)
		{
			case kSGRCodeBgBlack:
			case kSGRCodeFgBlack:
				thisAttributeValue = [NSColor blackColor];
				break;
			case kSGRCodeBgRed:
			case kSGRCodeFgRed:
				thisAttributeValue = [NSColor redColor];
				break;
			case kSGRCodeBgGreen:
			case kSGRCodeFgGreen:
				thisAttributeValue = [NSColor greenColor];
				break;
			case kSGRCodeBgYellow:
			case kSGRCodeFgYellow:
				thisAttributeValue = [NSColor yellowColor];
				break;
			case kSGRCodeBgBlue:
			case kSGRCodeFgBlue:
				thisAttributeValue = [NSColor blueColor];
				break;
			case kSGRCodeBgMagenta:
			case kSGRCodeFgMagenta:
				thisAttributeValue = [NSColor magentaColor];
				break;
			case kSGRCodeBgCyan:
			case kSGRCodeFgCyan:
				thisAttributeValue = [NSColor cyanColor];
				break;
			case kSGRCodeBgWhite:
			case kSGRCodeFgWhite:
				thisAttributeValue = [NSColor whiteColor];
				break;
			case kSGRCodeIntensityBold:
				{
				NSFont *boldFont = [[NSFontManager sharedFontManager] convertFont:self.font toHaveTrait:NSBoldFontMask];
				thisAttributeValue = boldFont;
				}
				break;
			case kSGRCodeIntensityNormal:
				{
				NSFont *unboldFont = [[NSFontManager sharedFontManager] convertFont:self.font toHaveTrait:NSUnboldFontMask];
				thisAttributeValue = unboldFont;
				}
				break;
			case kSGRCodeUnderlineSingle:
				thisAttributeValue = [NSNumber numberWithInteger:NSUnderlineStyleSingle];
				break;
			case kSGRCodeUnderlineDouble:
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
				
				BOOL endsFormattingRun = NO;
				switch(thisCode)
				{
					case kSGRCodeFgBlack:
					case kSGRCodeFgRed:
					case kSGRCodeFgGreen:
					case kSGRCodeFgYellow:
					case kSGRCodeFgBlue:
					case kSGRCodeFgMagenta:
					case kSGRCodeFgCyan:
					case kSGRCodeFgWhite:
						endsFormattingRun = kCodeEndsFgFormatting(thisEndCodeCandidate);
						break;
					case kSGRCodeBgBlack:
					case kSGRCodeBgRed:
					case kSGRCodeBgGreen:
					case kSGRCodeBgYellow:
					case kSGRCodeBgBlue:
					case kSGRCodeBgMagenta:
					case kSGRCodeBgCyan:
					case kSGRCodeBgWhite:
						endsFormattingRun = kCodeEndsBgFormatting(thisEndCodeCandidate);
						break;
					case kSGRCodeIntensityBold:
					case kSGRCodeIntensityNormal:
						endsFormattingRun = kCodeEndsIntensityFormatting(thisEndCodeCandidate);
						break;
					case kSGRCodeUnderlineSingle:
					case kSGRCodeUnderlineDouble:
						endsFormattingRun = kCodeEndsUnderlineFormatting(thisEndCodeCandidate);
						break;
				}
				
				if (endsFormattingRun)
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





@end
