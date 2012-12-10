//
//  HOStringSense by Dirk Holtwick 2012, holtwick.it
//  Based on OMColorSense by by Ole Zorn, 2012
//  Licensed under BSD style license
//

#import "HOStringHelper.h"
#import "HOStringInfoButton.h"
#import "HOStringFrameView.h"
#import "HOPopoverViewController.h"

#define kHOStringHelperHighlightingDisabled	@"HOStringHelperHighlightingDisabled"

@implementation HOStringHelper

@synthesize stringButton = _stringButton;
@synthesize stringFrameView = _stringFrameView;
@synthesize textView = _textView;
@synthesize selectedStringRange = _selectedStringRange;
@synthesize selectedStringContent=_selectedStringContent;

#pragma mark - String Helper

static NSMutableCharacterSet *staticEscapeChars;

- (NSString *)escapeString:(NSString *)string {
    NSMutableString *result = [NSMutableString string];
    if(!staticEscapeChars) {
        staticEscapeChars = [NSMutableCharacterSet characterSetWithRange:NSMakeRange(0,32)];
        [staticEscapeChars addCharactersInString: @"\"\\"];
    }
    NSRange esc = [string rangeOfCharacterFromSet:staticEscapeChars];
    if (!esc.length) {
        [result appendString:string];
    }
    else {
        NSUInteger length = [string length];
        for (NSUInteger i = 0; i < length; i++) {
            unichar uc = [string characterAtIndex:i];
            switch (uc) {
                case '"':   [result appendString:@"\\\""]; break;
                case '\'':  [result appendString:@"\\\'"]; break;
                case '\\':  [result appendString:@"\\\\"]; break;
                case '\t':  [result appendString:@"\\t"]; break;
                case '\n':  [result appendString:@"\\n"]; break;
                case '\r':  [result appendString:@"\\r"]; break;
                case '\b':  [result appendString:@"\\b"]; break;
                case '\f':  [result appendString:@"\\f"]; break;
                default: {
                    if (uc < 0x20) {
                        [result appendFormat:@"\\u%04x", uc];
                    }
                    else {
                        CFStringAppendCharacters((CFMutableStringRef)result, &uc, 1);
                    }
                } break;
            }
        }
    }
    return (NSString *)result;
}

- (NSString *)unescapeString:(NSString *)string {
    @try {
        NSString *s = [NSString stringWithFormat:@"\"%@\"", string];
        return [NSJSONSerialization JSONObjectWithData:[s dataUsingEncoding:NSUTF8StringEncoding]
                                               options:NSJSONReadingAllowFragments
                                                 error:NULL];
    }
    @catch (NSException *exception) { ; }
    return nil;
}

#pragma mark - Plugin Initialization

+ (void)pluginDidLoad:(NSBundle *)plugin
{
	static id sharedPlugin = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedPlugin = [[self alloc] init];
	});
}

- (id)init
{
	if (self = [super init]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:) name:NSApplicationDidFinishLaunchingNotification object:nil];
		_selectedStringRange = NSMakeRange(NSNotFound, 0);
        _stringRegex = [[NSRegularExpression regularExpressionWithPattern:@"@\"((\\\\\"|.)*?)\""
                                                                  options:0
                                                                    error:NULL] retain];
	}
	return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	NSMenuItem *editMenuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
	if (editMenuItem) {
		[[editMenuItem submenu] addItem:[NSMenuItem separatorItem]];

		NSMenuItem *toggleColorHighlightingMenuItem = [[[NSMenuItem alloc] initWithTitle:@"Show Strings Under Caret" action:@selector(toggleColorHighlightingEnabled:) keyEquivalent:@""] autorelease];
		[toggleColorHighlightingMenuItem setTarget:self];
		[[editMenuItem submenu] addItem:toggleColorHighlightingMenuItem];


        //		NSMenuItem *insertColorMenuItem = [[[NSMenuItem alloc] initWithTitle:@"Insert Color..." action:@selector(insertColor:) keyEquivalent:@""] autorelease];
        //		[insertColorMenuItem setTarget:self];
        //		[[editMenuItem submenu] addItem:insertColorMenuItem];
	}

	BOOL highlightingEnabled = ![[NSUserDefaults standardUserDefaults] boolForKey:kHOStringHelperHighlightingDisabled];
	if (highlightingEnabled) {
        [self activateColorHighlighting];
	}
}

#pragma mark - Preferences

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	if ([menuItem action] == @selector(insertColor:)) {
		NSResponder *firstResponder = [[NSApp keyWindow] firstResponder];
		return ([firstResponder isKindOfClass:NSClassFromString(@"DVTSourceTextView")] && [firstResponder isKindOfClass:[NSTextView class]]);
	} else if ([menuItem action] == @selector(toggleColorHighlightingEnabled:)) {
		BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:kHOStringHelperHighlightingDisabled];
		[menuItem setState:enabled ? NSOffState : NSOnState];
		return YES;
    }
	return YES;
}

- (void)toggleColorHighlightingEnabled:(id)sender
{
	BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:kHOStringHelperHighlightingDisabled];
	[[NSUserDefaults standardUserDefaults] setBool:!enabled forKey:kHOStringHelperHighlightingDisabled];
	if (enabled) {
		[self activateColorHighlighting];
	} else {
		[self deactivateColorHighlighting];
	}
}

- (void)activateColorHighlighting
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionDidChange:) name:NSTextViewDidChangeSelectionNotification object:nil];
	if (!self.textView) {
		NSResponder *firstResponder = [[NSApp keyWindow] firstResponder];
		if ([firstResponder isKindOfClass:NSClassFromString(@"DVTSourceTextView")] && [firstResponder isKindOfClass:[NSTextView class]]) {
			self.textView = (NSTextView *)firstResponder;
		}
	}
	if (self.textView) {
		NSNotification *notification = [NSNotification notificationWithName:NSTextViewDidChangeSelectionNotification object:self.textView];
		[self selectionDidChange:notification];

	}
}

- (void)deactivateColorHighlighting
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSTextViewDidChangeSelectionNotification object:nil];
	[self dismissPopover];
	self.textView = nil;
}

#pragma mark - Text Selection Handling

- (void)selectionDidChange:(NSNotification *)notification
{
	if ([[notification object] isKindOfClass:NSClassFromString(@"DVTSourceTextView")] && [[notification object] isKindOfClass:[NSTextView class]]) {
		self.textView = (NSTextView *)[notification object];

		BOOL disabled = [[NSUserDefaults standardUserDefaults] boolForKey:kHOStringHelperHighlightingDisabled];
		if (disabled) return;
		NSArray *selectedRanges = [self.textView selectedRanges];
		if (selectedRanges.count >= 1) {
			NSRange selectedRange = [[selectedRanges objectAtIndex:0] rangeValue];
			NSString *text = self.textView.textStorage.string;
			NSRange lineRange = [text lineRangeForRange:selectedRange];
			NSRange selectedRangeInLine = NSMakeRange(selectedRange.location - lineRange.location, selectedRange.length);
			NSString *line = [text substringWithRange:lineRange];

			NSRange colorRange = NSMakeRange(NSNotFound, 0);
            self.selectedStringContent = [self stringInText:line selectedRange:selectedRangeInLine matchedRange:&colorRange];
			if (_selectedStringContent) {
                self.selectedStringContent = [_selectedStringContent substringWithRange:NSMakeRange(2, _selectedStringContent.length - 3)];
				NSColor *backgroundColor = [self.textView.backgroundColor colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
				CGFloat r = 1.0; CGFloat g = 1.0; CGFloat b = 1.0;
				[backgroundColor getRed:&r green:&g blue:&b alpha:NULL];
				CGFloat backgroundLuminance = (r + g + b) / 3.0;

				NSColor *strokeColor = (backgroundLuminance > 0.5) ? [NSColor colorWithCalibratedWhite:0.2 alpha:1.0] : [NSColor colorWithCalibratedWhite:1.000 alpha:0.900];

				self.selectedStringRange = NSMakeRange(colorRange.location + lineRange.location, colorRange.length);
				NSRect selectionRectOnScreen = [self.textView firstRectForCharacterRange:self.selectedStringRange];
				NSRect selectionRectInWindow = [self.textView.window convertRectFromScreen:selectionRectOnScreen];
				NSRect selectionRectInView = [self.textView convertRect:selectionRectInWindow fromView:nil];

				// NSRect buttonRect = NSMakeRect(NSMaxX(selectionRectInView) - 49, NSMinY(selectionRectInView) - selectionRectInView.size.height - 2, 50, selectionRectInView.size.height + 2);
                NSRect buttonRect = NSMakeRect(NSMinX(selectionRectInView), NSMinY(selectionRectInView) - selectionRectInView.size.height - 2, 50, selectionRectInView.size.height + 2);
				self.stringButton.frame = NSIntegralRect(buttonRect);
                self.stringButton.title = [NSString stringWithFormat:@"%d", (int)[[self unescapeString:_selectedStringContent] length]];
                self.stringButton.strokeColor = strokeColor;
				[self.textView addSubview:self.stringButton];

				self.stringFrameView.frame = NSInsetRect(NSIntegralRect(selectionRectInView), -1, -1);
				self.stringFrameView.color = strokeColor;
				[self.textView addSubview:self.stringFrameView];
			} else {
				[self dismissPopover];
			}
		} else {
			[self dismissPopover];
		}
	}
}

- (void)dismissPopover
{
    if(_stringPopover) {
        [_stringPopover close];
        [_stringPopover autorelease];
    }
	[self.stringButton removeFromSuperview];
	[self.stringFrameView removeFromSuperview];
	self.selectedStringRange = NSMakeRange(NSNotFound, 0);
	self.selectedStringContent = nil;
}

- (void)stringDidChange:(id)sender {
	if (self.selectedStringRange.location == NSNotFound) {
		return;
	}
    NSTextField *textfield = (id)_stringPopoverViewController.view;
    NSString *result = textfield.stringValue;
    if(result) {
        result = [self escapeString:result];
        if(![result isEqualToString:_selectedStringContent]) {
            [self.textView.undoManager beginUndoGrouping];
            [self.textView insertText:[NSString stringWithFormat:@"@\"%@\"", result]
                     replacementRange:self.selectedStringRange];
            [self.textView.undoManager endUndoGrouping];
        }
    }
}

- (void)popoverWillClose:(NSNotification *)notification {
    [self stringDidChange:nil];
}

- (void)showPopover:(id)sender {
    if(_stringPopover) {
        [_stringPopover close];
        [_stringPopover autorelease];
    }    
    if(!_stringPopoverViewController) {
        _stringPopoverViewController = [[[HOPopoverViewController alloc] init] autorelease];
        _stringPopoverViewController.delegate = self;
    }
    NSTextField *textfield = (id)_stringPopoverViewController.view;
    textfield.stringValue = [self unescapeString:_selectedStringContent];
    textfield.font = self.textView.font;
    NSSize size = NSMakeSize(self.textView.bounds.size.width * 0.50, 120);
    _stringPopover = [[NSPopover alloc] init];
    _stringPopover.contentViewController = _stringPopoverViewController;
    _stringPopover.contentSize = size;
    _stringPopover.delegate = self;
    [_stringPopover showRelativeToRect:self.stringButton.bounds
                                ofView:self.stringButton
                         preferredEdge:NSMinYEdge];
}

#pragma mark - View Initialization

- (HOStringInfoButton *)stringButton
{
	if (!_stringButton) {
		_stringButton = [[HOStringInfoButton alloc] initWithFrame:NSMakeRect(0, 0, 100, 30)];
		[_stringButton setTarget:self];
		[_stringButton setAction:@selector(showPopover:)];
	}
	return _stringButton;
}

- (HOStringFrameView *)stringFrameView
{
	if (!_stringFrameView) {
		_stringFrameView = [[HOStringFrameView alloc] initWithFrame:NSZeroRect];
	}
	return _stringFrameView;
}

#pragma mark - Color String Parsing

- (NSString *)stringInText:(NSString *)text selectedRange:(NSRange)selectedRange matchedRange:(NSRangePointer)matchedRange
{
	__block NSString *foundStringContent = nil;
	__block NSRange foundColorRange = NSMakeRange(NSNotFound, 0);
	[_stringRegex enumerateMatchesInString:text options:0 range:NSMakeRange(0, text.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		NSRange colorRange = [result range];
		if (selectedRange.location >= colorRange.location && NSMaxRange(selectedRange) <= NSMaxRange(colorRange)) {
			foundStringContent = [text substringWithRange:[result rangeAtIndex:0]];
			foundColorRange = colorRange;
			*stop = YES;
		}
	}];
    if (foundStringContent) {
		if (matchedRange != NULL) {
			*matchedRange = foundColorRange;
		}
		return foundStringContent;
	}
    return nil;
}

#pragma mark -

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dismissPopover];
    [_stringPopoverViewController release];
    [_selectedStringContent release];
	[_stringButton release];
	[_stringFrameView release];
	[_textView release];
    [_stringRegex release];
	[super dealloc];
}

@end
