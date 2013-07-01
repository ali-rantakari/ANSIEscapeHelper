# ANSIEscapeHelper

This is an Objective-C class for dealing with ANSI escape sequences. Its main purpose is to translate between `NSString`s that contain ANSI escape sequences and similarly formatted `NSAttributedString`s.

Here's a quick and simple example of how you'd most likely want to use this class:

    AMR_ANSIEscapeHelper *ansiEscapeHelper =
        [[[AMR_ANSIEscapeHelper alloc] init] autorelease];
    
    // display an ANSI-escaped string in a text view:
    NSString *ansiEscapedStr =
        @"Let's pretend this string contains ANSI escape sequences";
    NSAttributedString *attrStr = [ansiEscapeHelper
         attributedStringWithANSIEscapedString:ansiEscapedStr];
    [[nsTextViewInstance textStorage] setAttributedString:attrStr];
    
    // get an ANSI-escaped string from a text view:
    NSAttributedString *attrStr = [nsTextViewInstance textStorage];
    NSString *ansiEscapedStr = [ansiEscapeHelper
         ansiEscapedStringWithAttributedString:attrStr];
