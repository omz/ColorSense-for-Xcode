//
//  HOStringSense by Dirk Holtwick 2012, holtwick.it
//  Based on OMColorSense by by Ole Zorn, 2012
//  Licensed under BSD style license
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
