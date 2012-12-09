//
//  Copyright 2012 Dirk Holtwick, holtwick.it. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class HOStringFrameView, HOStringInfoButton, HOStringViewController;

@interface HOStringHelper : NSObject {
    HOStringViewController *_stringViewController;
	HOStringInfoButton *_stringButton;
	HOStringFrameView *_stringFrameView;
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

- (void)dismissColorWell;
- (void)activateColorHighlighting;
- (void)deactivateColorHighlighting;
- (NSString *)stringInText:(NSString *)text selectedRange:(NSRange)selectedRange matchedRange:(NSRangePointer)matchedRange;
- (double)dividedValue:(double)value withDivisorRange:(NSRange)divisorRange inString:(NSString *)text;

@end
