//
//  Copyright 2012 Dirk Holtwick, holtwick.it. All rights reserved.
//

#import "HOStringHelper.h"
#import "HOStringInfoButton.h"
#import "HOStringFrameView.h"
#import "HOPopoverViewController.h"

#define kOMColorHelperHighlightingDisabled	@"OMColorHelperHighlightingDisabled"
#define kOMColorHelperInsertionMode			@"OMColorHelperInsertionMode"

@implementation HOStringHelper

@synthesize stringButton = _stringButton;
@synthesize stringFrameView = _stringFrameView;
@synthesize textView = _textView;
@synthesize selectedStringRange = _selectedStringRange;
@synthesize selectedStringContent=_selectedStringContent;

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
    //	NSMenuItem *editMenuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    //	if (editMenuItem) {
    //		[[editMenuItem submenu] addItem:[NSMenuItem separatorItem]];
    //
    //		NSMenuItem *toggleColorHighlightingMenuItem = [[[NSMenuItem alloc] initWithTitle:@"Show Colors Under Caret" action:@selector(toggleColorHighlightingEnabled:) keyEquivalent:@""] autorelease];
    //		[toggleColorHighlightingMenuItem setTarget:self];
    //		[[editMenuItem submenu] addItem:toggleColorHighlightingMenuItem];
    //
    //		NSMenuItem *colorInsertionModeItem = [[[NSMenuItem alloc] initWithTitle:@"Color Insertion Mode" action:nil keyEquivalent:@""] autorelease];
    //		NSMenuItem *colorInsertionModeNSItem = [[[NSMenuItem alloc] initWithTitle:@"NSColor" action:@selector(selectNSColorInsertionMode:) keyEquivalent:@""] autorelease];
    //		[colorInsertionModeNSItem setTarget:self];
    //		NSMenuItem *colorInsertionModeUIItem = [[[NSMenuItem alloc] initWithTitle:@"UIColor" action:@selector(selectUIColorInsertionMode:) keyEquivalent:@""] autorelease];
    //		[colorInsertionModeUIItem setTarget:self];
    //
    //		NSMenu *colorInsertionModeMenu = [[[NSMenu alloc] initWithTitle:@"Color Insertion Mode"] autorelease];
    //		[colorInsertionModeItem setSubmenu:colorInsertionModeMenu];
    //		[[colorInsertionModeItem submenu] addItem:colorInsertionModeUIItem];
    //		[[colorInsertionModeItem submenu] addItem:colorInsertionModeNSItem];
    //		[[editMenuItem submenu] addItem:colorInsertionModeItem];
    //
    //		NSMenuItem *insertColorMenuItem = [[[NSMenuItem alloc] initWithTitle:@"Insert Color..." action:@selector(insertColor:) keyEquivalent:@""] autorelease];
    //		[insertColorMenuItem setTarget:self];
    //		[[editMenuItem submenu] addItem:insertColorMenuItem];
    //	}
    //
    //	BOOL highlightingEnabled = ![[NSUserDefaults standardUserDefaults] boolForKey:kOMColorHelperHighlightingDisabled];
    //	if (highlightingEnabled) {
    [self activateColorHighlighting];
    //	}
}

#pragma mark - Preferences

//- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
//{
//	if ([menuItem action] == @selector(insertColor:)) {
//		NSResponder *firstResponder = [[NSApp keyWindow] firstResponder];
//		return ([firstResponder isKindOfClass:NSClassFromString(@"DVTSourceTextView")] && [firstResponder isKindOfClass:[NSTextView class]]);
//	} else if ([menuItem action] == @selector(toggleColorHighlightingEnabled:)) {
//		BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:kOMColorHelperHighlightingDisabled];
//		[menuItem setState:enabled ? NSOffState : NSOnState];
//		return YES;
//	} else if ([menuItem action] == @selector(selectNSColorInsertionMode:)) {
//		[menuItem setState:[[NSUserDefaults standardUserDefaults] integerForKey:kOMColorHelperInsertionMode] == 1 ? NSOnState : NSOffState];
//	} else if ([menuItem action] == @selector(selectUIColorInsertionMode:)) {
//		[menuItem setState:[[NSUserDefaults standardUserDefaults] integerForKey:kOMColorHelperInsertionMode] == 0 ? NSOnState : NSOffState];
//	}
//	return YES;
//}

//- (void)selectNSColorInsertionMode:(id)sender
//{
//	[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:kOMColorHelperInsertionMode];
//}

//- (void)selectUIColorInsertionMode:(id)sender
//{
//	[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:kOMColorHelperInsertionMode];
//}

//- (void)toggleColorHighlightingEnabled:(id)sender
//{
//	BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:kOMColorHelperHighlightingDisabled];
//	[[NSUserDefaults standardUserDefaults] setBool:!enabled forKey:kOMColorHelperHighlightingDisabled];
//	if (enabled) {
//		[self activateColorHighlighting];
//	} else {
//		[self deactivateColorHighlighting];
//	}
//}

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
	[self dismissColorWell];
	// self.textView = nil;
}

#pragma mark - Color Insertion

//- (void)insertColor:(id)sender
//{
//	if (!self.textView) {
//		NSResponder *firstResponder = [[NSApp keyWindow] firstResponder];
//		if ([firstResponder isKindOfClass:NSClassFromString(@"DVTSourceTextView")] && [firstResponder isKindOfClass:[NSTextView class]]) {
//			self.textView = (NSTextView *)firstResponder;
//		} else {
//			NSBeep();
//			return;
//		}
//	}
//	if ([[NSUserDefaults standardUserDefaults] boolForKey:kOMColorHelperHighlightingDisabled]) {
//		//Inserting a color implicitly activates color highlighting:
//		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:kOMColorHelperHighlightingDisabled];
//		[self activateColorHighlighting];
//	}
//	[self.textView.undoManager beginUndoGrouping];
//	NSInteger insertionMode = [[NSUserDefaults standardUserDefaults] integerForKey:kOMColorHelperInsertionMode];
//	if (insertionMode == 0) {
//		[self.textView insertText:@"[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]" replacementRange:self.textView.selectedRange];
//	} else {
//		[self.textView insertText:@"[NSColor colorWithCalibratedRed:1.0 green:0.0 blue:0.0 alpha:1.0]" replacementRange:self.textView.selectedRange];
//	}
//	[self.textView.undoManager endUndoGrouping];
//	[self performSelector:@selector(activateColorWell) withObject:nil afterDelay:0.0];
//}

//- (void)activateColorWell
//{
//	// [self.colorWell activate:YES];
//}

#pragma mark - Text Selection Handling

- (void)selectionDidChange:(NSNotification *)notification
{
	if ([[notification object] isKindOfClass:NSClassFromString(@"DVTSourceTextView")] && [[notification object] isKindOfClass:[NSTextView class]]) {
		self.textView = (NSTextView *)[notification object];

		BOOL disabled = [[NSUserDefaults standardUserDefaults] boolForKey:kOMColorHelperHighlightingDisabled];
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

				NSColor *strokeColor = (backgroundLuminance > 0.5) ? [NSColor colorWithCalibratedWhite:0.2 alpha:1.0] : [NSColor whiteColor];

				self.selectedStringRange = NSMakeRange(colorRange.location + lineRange.location, colorRange.length);
				NSRect selectionRectOnScreen = [self.textView firstRectForCharacterRange:self.selectedStringRange];
				NSRect selectionRectInWindow = [self.textView.window convertRectFromScreen:selectionRectOnScreen];
				NSRect selectionRectInView = [self.textView convertRect:selectionRectInWindow fromView:nil];
				NSRect colorWellRect = NSMakeRect(NSMaxX(selectionRectInView) - 49, NSMinY(selectionRectInView) - selectionRectInView.size.height - 2, 50, selectionRectInView.size.height + 2);

				self.stringButton.frame = NSIntegralRect(colorWellRect);
				[self.textView addSubview:self.stringButton];

				self.stringFrameView.frame = NSInsetRect(NSIntegralRect(selectionRectInView), -1, -1);
				self.stringFrameView.color = strokeColor;
				[self.textView addSubview:self.stringFrameView];
			} else {
				[self dismissColorWell];
			}
		} else {
			[self dismissColorWell];
		}
	}
}

- (void)dismissColorWell
{
//	if (self.colorWell.isActive) {
//		[self.colorWell deactivate];
//		[[NSColorPanel sharedColorPanel] orderOut:nil];
//	}
	[self.stringButton removeFromSuperview];
	[self.stringFrameView removeFromSuperview];
	self.selectedStringRange = NSMakeRange(NSNotFound, 0);
	self.selectedStringContent = nil;
}

//- (NSString *)escapeString:(NSString *) {
//    NSMutableString *json = [NSMutableString string];
//    [json appendString:@"\""];
//
//    if(!kEscapeChars) {
//        kEscapeChars = [NSMutableCharacterSet characterSetWithRange:NSMakeRange(0,32)];
//        [kEscapeChars addCharactersInString: @"\"\\"];
//    }
//
//    NSRange esc = [self rangeOfCharacterFromSet:kEscapeChars];
//    if ( !esc.length ) {
//        // No special chars -- can just add the raw string:
//        [json appendString:self];
//
//    }
//    else {
//        NSUInteger length = [self length];
//        for (NSUInteger i = 0; i < length; i++) {
//            unichar uc = [self characterAtIndex:i];
//            switch (uc) {
//                case '"':   [json appendString:@"\\\""];       break;
//                case '\'':  [json appendString:@"\\\'"];       break;
//                    // case '%':  [json appendString:@"\\%"];        break;
//                case '\\':  [json appendString:@"\\\\"];       break;
//                case '\t':  [json appendString:@"\\t"];        break;
//                case '\n':  [json appendString:@"\\n"];        break;
//                case '\r':  [json appendString:@"\\r"];        break;
//                case '\b':  [json appendString:@"\\b"];        break;
//                case '\f':  [json appendString:@"\\f"];        break;
//                default: {
//                    if (uc < 0x20) {
//                        [json appendFormat:@"\\u%04x", uc];
//                    }
//                    else {
//                        CFStringAppendCharacters((__bridge CFMutableStringRef)json, &uc, 1);
//                    }
//                }
//                    break;
//            }
//        }
//    }
//
//    [json appendString:@"\""];
//    return (NSString *)json;
//}

- (void)colorDidChange:(id)sender
{
	if (self.selectedStringRange.location == NSNotFound) {
		return;
	}
    // FIXME:dholtwick:2012-12-09 -
	NSString *colorString = self.selectedStringContent;
	if (colorString) {
		[self.textView.undoManager beginUndoGrouping];
		[self.textView insertText:colorString replacementRange:self.selectedStringRange];
		[self.textView.undoManager endUndoGrouping];
	}
}

- (void)showPopover:(id)sender {
    NSString *s = [NSString stringWithFormat:@"\"%@\"", _selectedStringContent];
    id value =
    [NSJSONSerialization JSONObjectWithData:[s dataUsingEncoding:NSUTF8StringEncoding]
                                    options:NSJSONReadingAllowFragments
                                      error:NULL]; 
    HOPopoverViewController *vc = [[[HOPopoverViewController alloc] init] autorelease];
    NSTextField *textfield = (id)vc.view;
    textfield.stringValue = value;
    textfield.font = self.textView.font;
    NSSize size = NSMakeSize(self.textView.bounds.size.width * 0.75, 120);
    NSPopover *popover = [[NSPopover alloc] init];
    popover.contentViewController = vc;
    popover.contentSize = size;
    [popover showRelativeToRect:self.stringButton.bounds
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
    NSLog(@"Found %@", foundStringContent);
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
    [_selectedStringContent release];
	[_stringButton release];
	[_stringFrameView release];
	[_textView release];
    [_stringRegex release];
	[super dealloc];
}

@end
