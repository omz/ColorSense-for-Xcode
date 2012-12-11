//
//  HOStringSense by Dirk Holtwick 2012, holtwick.it
//  Based on OMColorSense by by Ole Zorn, 2012
//  Licensed under BSD style license
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class HOStringFrameView, HOStringInfoButton, HOPopoverViewController;

@interface HOStringHelper : NSObject <NSPopoverDelegate> {
	HOStringInfoButton *_stringButton;
	HOStringFrameView *_stringFrameView;
    HOPopoverViewController *_stringPopoverViewController;
    NSPopover *_stringPopover;
	NSRange _selectedStringRange;
	NSString *_selectedStringContent;
	NSTextView *_textView;
	NSRegularExpression *_stringRegex;
}

@property (nonatomic, retain) HOStringInfoButton *stringButton;
@property (nonatomic, retain) HOStringFrameView *stringFrameView;
@property (nonatomic, retain) NSTextView *textView;
@property (nonatomic, assign) NSRange selectedStringRange;
@property (nonatomic, copy) NSString *selectedStringContent;

- (void)dismissPopover;
- (void)activateColorHighlighting;
- (void)deactivateColorHighlighting;
- (NSString *)stringInText:(NSString *)text selectedRange:(NSRange)selectedRange matchedRange:(NSRangePointer)matchedRange;

- (NSString *)escapeString:(NSString *)string;
- (NSString *)unescapeString:(NSString *)string;

@end
