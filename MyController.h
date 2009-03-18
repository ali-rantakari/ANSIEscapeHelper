#import <Cocoa/Cocoa.h>

@interface MyController : NSObject {
    IBOutlet NSButton *button;
    IBOutlet NSTextView *textView;
}
- (IBAction)buttonPress:(id)sender;
- (NSString *) runTaskWithPath:(NSString *)path withArgs:(NSArray *)args;
@end
