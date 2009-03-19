#import <Cocoa/Cocoa.h>
#import "ANSIEscapeHelper.h"

@interface MyController : NSObject
{
    IBOutlet NSButton *button;
    IBOutlet NSTextView *textView;
	
	ANSIEscapeHelper *ansiEscapeHelper;
}

- (IBAction) cProgramButtonPress:(id)sender;
- (IBAction) icalBuddyButtonPress:(id)sender;
- (IBAction) perlScriptButtonPress:(id)sender;
- (IBAction) oneCharPerlScriptButtonPress:(id)sender;

- (void) showString:(NSString*)string;
- (NSString *) runTaskWithPath:(NSString *)path withArgs:(NSArray *)args;

@end
