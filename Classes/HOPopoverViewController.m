//
//  Copyright 2012 Dirk Holtwick, holtwick.it. All rights reserved.
//

#import "HOPopoverViewController.h"

@implementation HOPopoverViewController

- (NSView *)view {
    NSTextField *textfield = [[[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 200)] autorelease];
    textfield.focusRingType = NSFocusRingTypeNone;
    textfield.bordered = NO;
    [super setView:textfield];
    return [super view];
}

@end
