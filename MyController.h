#import <Cocoa/Cocoa.h>
#import "AMR_ANSIEscapeHelper.h"

@interface MyController : NSObject
{
    IBOutlet NSButton *button;
    IBOutlet NSTextView *textView;
	
	AMR_ANSIEscapeHelper *ansiEscapeHelper;
}

- (IBAction) cProgramButtonPress:(id)sender;
- (IBAction) icalBuddyButtonPress:(id)sender;
- (IBAction) perlScriptButtonPress:(id)sender;
- (IBAction) oneCharPerlScriptButtonPress:(id)sender;

- (void) showString:(NSString*)string;
- (NSString *) runTaskWithPath:(NSString *)path withArgs:(NSArray *)args;

@end
