#import <Cocoa/Cocoa.h>
#import "ANSIEscapeFormatter.h"

@interface MyController : NSObject
{
    IBOutlet NSButton *button;
    IBOutlet NSTextView *textView;
	
	ANSIEscapeFormatter *ansiFormatter;
}

- (IBAction)buttonPress:(id)sender;
- (NSString *) runTaskWithPath:(NSString *)path withArgs:(NSArray *)args;

@end
