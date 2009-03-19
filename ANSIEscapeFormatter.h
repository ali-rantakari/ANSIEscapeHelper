//
//  ANSIEscapeFormatter.h
//  AnsiColorsTest
//
//  Created by Ali Rantakari on 18.3.09.
//  Copyright 2009 Ali Rantakari. All rights reserved.
//

#import <Cocoa/Cocoa.h>


/*!
 @class ANSIEscapeFormatter
 @abstract Contains helper methods for dealing with strings
 that contain ANSI escape sequences for formatting (colors,
 underlining, bold etc.)
 */
@interface ANSIEscapeFormatter : NSObject
{
	NSFont *font;
}

@property(retain) NSFont *font;

/*!
 @method attributesForString:cleanString:
 @abstract Convert ANSI escape sequences in a string to string formatting attributes
 @discussion Given a string with some ANSI escape sequences in it, this method returns
 attributes for formatting the specified string according to those ANSI escape sequences
 as well as a "clean" (i.e. free of the escape sequences) version of this string.
 @param aString A String containing ANSI escape sequences
 @param aCleanString Upon return, contains a "clean" version of aString (i.e. aString
 without the ANSI escape sequences)
 @result An array containing NSDictionary objects, each of which has keys "range" (an
 NSValue containing an NSRange, which specifies the range for the attribute within the
 "clean" version of aString), "attributeName" (an NSString) and "attributeValue" (an
 NSObject). You may use these as arguments for NSMutableAttributedString's methods
 for setting the formatting.
 */
- (NSArray*) attributesForString:(NSString*)aString cleanString:(NSString**)aCleanString;

@end
