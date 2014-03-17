//
//  HOStringSense by Dirk Holtwick 2012, holtwick.it
//  Based on OMColorSense by by Ole Zorn, 2012
//  Licensed under BSD style license
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class HOStringFrameView, HOStringInfoButton, HOPopoverViewController;

@interface HOStringHelper : NSObject <NSPopoverDelegate> {
    HOPopoverViewController *_stringPopoverViewController;
    NSPopover *_stringPopover;
	NSRegularExpression *_stringRegex;
}

@property (nonatomic, strong) HOStringInfoButton *stringButton;
@property (nonatomic, strong) HOStringFrameView *stringFrameView;
@property (nonatomic, strong) NSTextView *textView;
@property (nonatomic, assign) NSRange selectedStringRange;
@property (nonatomic, copy) NSString *selectedStringContent;

- (void)dismissPopover;
- (void)activateColorHighlighting;
- (void)deactivateColorHighlighting;
- (NSString *)stringInText:(NSString *)text selectedRange:(NSRange)selectedRange matchedRange:(NSRangePointer)matchedRange;

- (NSString *)escapeString:(NSString *)string;
- (NSString *)unescapeString:(NSString *)string;

@end
