//
//  HOStringSense by Dirk Holtwick 2012, holtwick.it
//  Based on OMColorSense by by Ole Zorn, 2012
//  Licensed under BSD style license
//

#import <Cocoa/Cocoa.h>

@interface HOPopoverViewController : NSViewController <NSTextFieldDelegate> {
    NSTextField *_textField;
}

@property (weak, nonatomic) id delegate;

@end
