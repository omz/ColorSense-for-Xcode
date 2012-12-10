//
//  HOStringSense by Dirk Holtwick 2012, holtwick.it
//  Based on OMColorSense by by Ole Zorn, 2012
//  Licensed under BSD style license
//

#import "HOPopoverViewController.h"

@implementation HOPopoverViewController

@synthesize delegate = _delegate;

- (NSView *)view {
    if(!_textField) {
        _textField = [[[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 200)] autorelease];
        _textField.focusRingType = NSFocusRingTypeNone;
        _textField.bordered = NO;
        _textField.backgroundColor = [NSColor colorWithCalibratedWhite:0.974 alpha:1.000];
        _textField.textColor = [NSColor colorWithCalibratedWhite:0.107 alpha:1.000];
        _textField.delegate = self;
    }
    return _textField;
}

- (void)dealloc {
    _delegate = nil;
    [_textField release];
    [super dealloc];
}

- (void)controlTextDidChange:(NSNotification *)obj {
    // NSLog(@"Test: %@", [_textField stringValue]);
    if([_delegate respondsToSelector:@selector(stringDidChange:)]) {
        [_delegate performSelector:@selector(stringDidChange:) withObject:nil];
    }
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    // NSLog(@"Textview Command: %@", NSStringFromSelector(commandSelector));
    if(commandSelector == @selector(cancelOperation:) || commandSelector == @selector(insertNewline:)) {
        if([_delegate respondsToSelector:@selector(dismissPopover)]) {
            [_delegate performSelector:@selector(dismissPopover)];
        }
        return YES;
    }
    return NO;
}

@end
