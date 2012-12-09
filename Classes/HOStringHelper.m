//
//  OMColorHelper.m
//  OMColorHelper
//
//  Created by Ole Zorn on 09/07/12.
//
//

#import "HOStringHelper.h"
#import "HOStringInfoButton.h"
#import "HOStringFrameView.h"
#import "HOPopoverViewController.h"

#define kOMColorHelperHighlightingDisabled	@"OMColorHelperHighlightingDisabled"
#define kOMColorHelperInsertionMode			@"OMColorHelperInsertionMode"

@implementation HOStringHelper

@synthesize colorWell=_colorWell, colorFrameView=_colorFrameView, textView=_textView, selectedColorRange=_selectedColorRange, selectedColorType=_selectedColorType;

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
		_selectedColorRange = NSMakeRange(NSNotFound, 0);
        _stringRegex = [[NSRegularExpression regularExpressionWithPattern:@"@\"(\\\\\"|.)*?\""
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

		NSMenuItem *toggleColorHighlightingMenuItem = [[[NSMenuItem alloc] initWithTitle:@"Show Colors Under Caret" action:@selector(toggleColorHighlightingEnabled:) keyEquivalent:@""] autorelease];
		[toggleColorHighlightingMenuItem setTarget:self];
		[[editMenuItem submenu] addItem:toggleColorHighlightingMenuItem];

		NSMenuItem *colorInsertionModeItem = [[[NSMenuItem alloc] initWithTitle:@"Color Insertion Mode" action:nil keyEquivalent:@""] autorelease];
		NSMenuItem *colorInsertionModeNSItem = [[[NSMenuItem alloc] initWithTitle:@"NSColor" action:@selector(selectNSColorInsertionMode:) keyEquivalent:@""] autorelease];
		[colorInsertionModeNSItem setTarget:self];
		NSMenuItem *colorInsertionModeUIItem = [[[NSMenuItem alloc] initWithTitle:@"UIColor" action:@selector(selectUIColorInsertionMode:) keyEquivalent:@""] autorelease];
		[colorInsertionModeUIItem setTarget:self];

		NSMenu *colorInsertionModeMenu = [[[NSMenu alloc] initWithTitle:@"Color Insertion Mode"] autorelease];
		[colorInsertionModeItem setSubmenu:colorInsertionModeMenu];
		[[colorInsertionModeItem submenu] addItem:colorInsertionModeUIItem];
		[[colorInsertionModeItem submenu] addItem:colorInsertionModeNSItem];
		[[editMenuItem submenu] addItem:colorInsertionModeItem];

		NSMenuItem *insertColorMenuItem = [[[NSMenuItem alloc] initWithTitle:@"Insert Color..." action:@selector(insertColor:) keyEquivalent:@""] autorelease];
		[insertColorMenuItem setTarget:self];
		[[editMenuItem submenu] addItem:insertColorMenuItem];
	}

	BOOL highlightingEnabled = ![[NSUserDefaults standardUserDefaults] boolForKey:kOMColorHelperHighlightingDisabled];
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
		BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:kOMColorHelperHighlightingDisabled];
		[menuItem setState:enabled ? NSOffState : NSOnState];
		return YES;
	} else if ([menuItem action] == @selector(selectNSColorInsertionMode:)) {
		[menuItem setState:[[NSUserDefaults standardUserDefaults] integerForKey:kOMColorHelperInsertionMode] == 1 ? NSOnState : NSOffState];
	} else if ([menuItem action] == @selector(selectUIColorInsertionMode:)) {
		[menuItem setState:[[NSUserDefaults standardUserDefaults] integerForKey:kOMColorHelperInsertionMode] == 0 ? NSOnState : NSOffState];
	}
	return YES;
}

- (void)selectNSColorInsertionMode:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:kOMColorHelperInsertionMode];
}

- (void)selectUIColorInsertionMode:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:kOMColorHelperInsertionMode];
}

- (void)toggleColorHighlightingEnabled:(id)sender
{
	BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:kOMColorHelperHighlightingDisabled];
	[[NSUserDefaults standardUserDefaults] setBool:!enabled forKey:kOMColorHelperHighlightingDisabled];
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
	[self dismissColorWell];
	//self.textView = nil;
}

#pragma mark - Color Insertion

- (void)insertColor:(id)sender
{
	if (!self.textView) {
		NSResponder *firstResponder = [[NSApp keyWindow] firstResponder];
		if ([firstResponder isKindOfClass:NSClassFromString(@"DVTSourceTextView")] && [firstResponder isKindOfClass:[NSTextView class]]) {
			self.textView = (NSTextView *)firstResponder;
		} else {
			NSBeep();
			return;
		}
	}
	if ([[NSUserDefaults standardUserDefaults] boolForKey:kOMColorHelperHighlightingDisabled]) {
		//Inserting a color implicitly activates color highlighting:
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:kOMColorHelperHighlightingDisabled];
		[self activateColorHighlighting];
	}
	[self.textView.undoManager beginUndoGrouping];
	NSInteger insertionMode = [[NSUserDefaults standardUserDefaults] integerForKey:kOMColorHelperInsertionMode];
	if (insertionMode == 0) {
		[self.textView insertText:@"[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]" replacementRange:self.textView.selectedRange];
	} else {
		[self.textView insertText:@"[NSColor colorWithCalibratedRed:1.0 green:0.0 blue:0.0 alpha:1.0]" replacementRange:self.textView.selectedRange];
	}
	[self.textView.undoManager endUndoGrouping];
	[self performSelector:@selector(activateColorWell) withObject:nil afterDelay:0.0];
}

- (void)activateColorWell
{
	// [self.colorWell activate:YES];
}

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
			OMColorType colorType = OMColorTypeNone;
			NSColor *matchedColor = [self colorInText:line selectedRange:selectedRangeInLine type:&colorType matchedRange:&colorRange];

			if (matchedColor) {
				NSColor *backgroundColor = [self.textView.backgroundColor colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
				CGFloat r = 1.0; CGFloat g = 1.0; CGFloat b = 1.0;
				[backgroundColor getRed:&r green:&g blue:&b alpha:NULL];
				CGFloat backgroundLuminance = (r + g + b) / 3.0;

				NSColor *strokeColor = (backgroundLuminance > 0.5) ? [NSColor colorWithCalibratedWhite:0.2 alpha:1.0] : [NSColor whiteColor];

				self.selectedColorType = colorType;


				// self.colorWell.color = matchedColor;
				// self.colorWell.strokeColor = strokeColor;

				self.selectedColorRange = NSMakeRange(colorRange.location + lineRange.location, colorRange.length);
				NSRect selectionRectOnScreen = [self.textView firstRectForCharacterRange:self.selectedColorRange];
				NSRect selectionRectInWindow = [self.textView.window convertRectFromScreen:selectionRectOnScreen];
				NSRect selectionRectInView = [self.textView convertRect:selectionRectInWindow fromView:nil];
				NSRect colorWellRect = NSMakeRect(NSMaxX(selectionRectInView) - 49, NSMinY(selectionRectInView) - selectionRectInView.size.height - 2, 50, selectionRectInView.size.height + 2);
				self.colorWell.frame = NSIntegralRect(colorWellRect);
				[self.textView addSubview:self.colorWell];
				self.colorFrameView.frame = NSInsetRect(NSIntegralRect(selectionRectInView), -1, -1);

				self.colorFrameView.color = strokeColor;

				[self.textView addSubview:self.colorFrameView];
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
	[self.colorWell removeFromSuperview];
	[self.colorFrameView removeFromSuperview];
	self.selectedColorRange = NSMakeRange(NSNotFound, 0);
	self.selectedColorType = OMColorTypeNone;
}

- (void)colorDidChange:(id)sender
{
	if (self.selectedColorRange.location == NSNotFound) {
		return;
	}
	NSString *colorString = [self colorStringForColor:nil withType:self.selectedColorType];
	if (colorString) {
		[self.textView.undoManager beginUndoGrouping];
		[self.textView insertText:colorString replacementRange:self.selectedColorRange];
		[self.textView.undoManager endUndoGrouping];
	}
}

- (void)showPopover:(id)sender {
    NSPopover *popover = [[NSPopover alloc] init];
    popover.contentViewController = [[HOPopoverViewController alloc] init];
    [popover showRelativeToRect:self.colorWell.bounds ofView:self.colorWell preferredEdge:NSMaxXEdge];
}

#pragma mark - View Initialization

- (HOStringInfoButton *)colorWell
{
	if (!_colorWell) {
		_colorWell = [[HOStringInfoButton alloc] initWithFrame:NSMakeRect(0, 0, 50, 30)];
		[_colorWell setTarget:self];
		[_colorWell setAction:@selector(showPopover:)];
	}
	return _colorWell;
}

- (HOStringFrameView *)colorFrameView
{
	if (!_colorFrameView) {
		_colorFrameView = [[HOStringFrameView alloc] initWithFrame:NSZeroRect];
	}
	return _colorFrameView;
}

#pragma mark - Color String Parsing

- (NSColor *)colorInText:(NSString *)text selectedRange:(NSRange)selectedRange type:(OMColorType *)type matchedRange:(NSRangePointer)matchedRange
{
	__block NSColor *foundColor = nil;
	__block NSRange foundColorRange = NSMakeRange(NSNotFound, 0);
	__block OMColorType foundColorType = OMColorTypeNone;

	[_stringRegex enumerateMatchesInString:text options:0 range:NSMakeRange(0, text.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		NSRange colorRange = [result range];
		if (selectedRange.location >= colorRange.location && NSMaxRange(selectedRange) <= NSMaxRange(colorRange)) {
			NSString *typeIndicator = [text substringWithRange:[result rangeAtIndex:1]];
			if ([typeIndicator rangeOfString:@"init"].location != NSNotFound) {
				foundColorType = OMColorTypeUIRGBAInit;
			} else {
				foundColorType = OMColorTypeUIRGBA;
			}
			foundColor = [NSColor redColor];
			foundColorRange = colorRange;
			*stop = YES;
		}
	}];
	if (foundColor) {
		if (matchedRange != NULL) {
			*matchedRange = foundColorRange;
		}
		if (type != NULL) {
			*type = foundColorType;
		}
		return foundColor;
	}

	return nil;
}

- (double)dividedValue:(double)value withDivisorRange:(NSRange)divisorRange inString:(NSString *)text
{
	if (divisorRange.location != NSNotFound) {
		double divisor = [[[text substringWithRange:divisorRange] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/ "]] doubleValue];
		if (divisor != 0) {
			value /= divisor;
		}
	}
	return value;
}

- (NSString *)colorStringForColor:(NSColor *)color withType:(OMColorType)colorType
{
    return @"xxx";
}

#pragma mark -

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_colorWell release];
	[_colorFrameView release];
	[_textView release];
    [_stringRegex release];
	[super dealloc];
}

@end
