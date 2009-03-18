//
//  ANSIEscapeFormatter.h
//  AnsiColorsTest
//
//  Created by Ali Rantakari on 18.3.09.
//  Copyright 2009 Ali Rantakari. All rights reserved.
//

#import <Cocoa/Cocoa.h>



@interface ANSIEscapeFormatter : NSObject
{
	
}

- (NSArray*) attributesForString:(NSString*)aString cleanString:(NSString**)aCleanString;
- (NSRange) rangeOfOneOfStrings:(NSArray*)aStrings inString:(NSString*)aSubject options:(NSStringCompareOptions)aOptions range:(NSRange)aRange;
- (NSString*) stripEscapeSequencesFromString:(NSString*)aString;

@end
