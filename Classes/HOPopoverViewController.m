//
//  Copyright 2012 Dirk Holtwick, holtwick.it. All rights reserved.
//

#import "HOPopoverViewController.h"

@implementation HOPopoverViewController

- (NSView *)view {
    if(!_textField) {
        _textField = [[[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 200)] autorelease];
        _textField.focusRingType = NSFocusRingTypeNone;
        _textField.bordered = NO;
    }
    return _textField;
}

- (void)dealloc {
    [_textField release];
    [super dealloc];
}

@end
