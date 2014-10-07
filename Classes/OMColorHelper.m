
//  OMColorHelper.m OMColorHelper Created by Ole Zorn on 09/07/12.

#import "OMColorHelper.h"
#import "OMPlainColorWell.h"
#import "OMColorFrameView.h"

#define kOMColorHelperHighlightingDisabled	@"OMColorHelperHighlightingDisabled"
#define kOMColorHelperInsertionMode         @"OMColorHelperInsertionMode"

#define kNCENTER [NSNotificationCenter  defaultCenter]
#define kUSRDEFS [NSUserDefaults standardUserDefaults]

@implementation OMColorHelper {



  NSDictionary        * _constantColorsByName;
	NSRegularExpression * _rgbaUIColorRegex,
                      * _rgbaNSColorRegex,
                      * _whiteNSColorRegex,
                      * _whiteUIColorRegex,
                      * _constantColorRegex;
}


//@synthesize colorWell=_colorWell, colorFrameView=_colorFrameView, textView=_textView, selectedColorRange=_selectedColorRange, selectedColorType=_selectedColorType;

#pragma mark - Plugin Initialization

+ (void)pluginDidLoad:(NSBundle *)plugin {


	static id sharedPlugin = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{ sharedPlugin = [[self alloc] init]; });
}

- (instancetype) init { if (!(self = super.init)) return nil;

  [kNCENTER addObserver:self selector:@selector(applicationDidFinishLaunching:)
                   name:NSApplicationDidFinishLaunchingNotification object:nil];
  _selectedColorRange   = NSMakeRange(NSNotFound, 0);
  _constantColorsByName = @{

    @"black"      : [NSColor.blackColor colorUsingColorSpace:NSColorSpace.genericRGBColorSpace],
    @"darkGray"   : NSColor.darkGrayColor,
    @"lightGray"  : NSColor.lightGrayColor,
    @"white"      : [NSColor.whiteColor colorUsingColorSpace:NSColorSpace.genericRGBColorSpace],
    @"gray"       : NSColor.grayColor,
    @"red"        : NSColor.redColor,
    @"green"      : NSColor.greenColor,
    @"blue"       : NSColor.blueColor,
    @"cyan"       : NSColor.cyanColor,
    @"yellow"     : NSColor.yellowColor,
    @"magenta"    : NSColor.magentaColor,
    @"orange"     : NSColor.orangeColor,
    @"purple"     : NSColor.purpleColor,
    @"brown"      : NSColor.brownColor,
    @"clear"      : [NSColor.clearColor colorUsingColorSpace:NSColorSpace.genericRGBColorSpace]
  };

  _rgbaUIColorRegex = [NSRegularExpression regularExpressionWithPattern:@"(\\[\\s*UIColor\\s+colorWith|\\[\\s*\\[\\s*UIColor\\s+alloc\\]\\s*initWith)Red:\\s*([0-9]*\\.?[0-9]*f?)\\s*(\\/\\s*[0-9]*\\.?[0-9]*f?)?\\s+green:\\s*([0-9]*\\.?[0-9]*f?)\\s*(\\/\\s*[0-9]*\\.?[0-9]*f?)?\\s+blue:\\s*([0-9]*\\.?[0-9]*f?)\\s*(\\/\\s*[0-9]*\\.?[0-9]*f?)?\\s*alpha:\\s*([0-9]*\\.?[0-9]*f?)\\s*(\\/\\s*[0-9]*\\.?[0-9]*f?)?\\s*\\]" options:0 error:NULL];
  _whiteUIColorRegex = [NSRegularExpression regularExpressionWithPattern:@"(\\[\\s*UIColor\\s+colorWith|\\[\\s*\\[\\s*UIColor\\s+alloc\\]\\s*initWith)White:\\s*([0-9]*\\.?[0-9]*f?)\\s*(\\/\\s*[0-9]*\\.?[0-9]*f?)?\\s+alpha:\\s*([0-9]*\\.?[0-9]*f?)\\s*(\\/\\s*[0-9]*\\.?[0-9]*f?)?\\s*\\]" options:0 error:NULL];
  _rgbaNSColorRegex = [NSRegularExpression regularExpressionWithPattern:@"\\[\\s*NSColor\\s+colorWith(Calibrated|Device)Red:\\s*([0-9]*\\.?[0-9]*f?)\\s*(\\/\\s*[0-9]*\\.?[0-9]*f?)?\\s+green:\\s*([0-9]*\\.?[0-9]*f?)\\s*(\\/\\s*[0-9]*\\.?[0-9]*f?)?\\s+blue:\\s*([0-9]*\\.?[0-9]*f?)\\s*(\\/\\s*[0-9]*\\.?[0-9]*f?)?\\s+alpha:\\s*([0-9]*\\.?[0-9]*f?)\\s*(\\/\\s*[0-9]*\\.?[0-9]*f?)?\\s*\\]" options:0 error:NULL];
  _whiteNSColorRegex = [NSRegularExpression regularExpressionWithPattern:@"\\[\\s*NSColor\\s+colorWith(Calibrated|Device)White:\\s*([0-9]*\\.?[0-9]*f?)\\s*(\\/\\s*[0-9]*\\.?[0-9]*f?)?\\s+alpha:\\s*([0-9]*\\.?[0-9]*f?)\\s*(\\/\\s*[0-9]*\\.?[0-9]*f?)?\\s*\\]" options:0 error:NULL];
  _constantColorRegex = [NSRegularExpression regularExpressionWithPattern:@"\\[\\s*(UI|NS)Color\\s+(black|darkGray|lightGray|white|gray|red|green|blue|cyan|yellow|magenta|orange|purple|brown|clear)Color\\s*\\]" options:0 error:NULL];
	return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)_ {

	NSMenuItem *editMenuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
	if (editMenuItem) {
		[editMenuItem.submenu addItem:NSMenuItem.separatorItem];
		
		NSMenuItem *toggleHighlightMenuItem   = [NSMenuItem.alloc initWithTitle:@"Show Colors Under Caret"
                                                                           action:@selector(toggleColorHighlightingEnabled:) keyEquivalent:@""];
		toggleHighlightMenuItem.target       = self;

		[editMenuItem.submenu addItem:toggleHighlightMenuItem];
		
		NSMenuItem *colorInsertionModeItem   = [NSMenuItem.alloc initWithTitle:@"Color Insertion Mode"
                                                                    action:nil
                                                             keyEquivalent:@""];
		NSMenuItem *colorInsertionModeNSItem = [NSMenuItem.alloc initWithTitle:@"NSColor"
                                                                    action:@selector(selectNSColorInsertionMode:)
                                                             keyEquivalent:@""];
		colorInsertionModeNSItem.target      = self;
		NSMenuItem *colorInsertionModeUIItem = [NSMenuItem.alloc initWithTitle:@"UIColor"
                                                                    action:@selector(selectUIColorInsertionMode:)
                                                             keyEquivalent:@""];
		colorInsertionModeUIItem.target      = self;
		
		NSMenu *colorInsertionModeMenu       = [NSMenu.alloc initWithTitle:@"Color Insertion Mode"];
		colorInsertionModeItem.submenu       = colorInsertionModeMenu;

    [colorInsertionModeItem.submenu addItem:colorInsertionModeUIItem];
		[colorInsertionModeItem.submenu addItem:colorInsertionModeNSItem];
		[editMenuItem.submenu addItem:colorInsertionModeItem];
		
		NSMenuItem *insertColorMenuItem      = [NSMenuItem.alloc initWithTitle:@"Insert Color..."
                                                               action:@selector(insertColor:)
                                                        keyEquivalent:@""];
		insertColorMenuItem.target           = self;
		[editMenuItem.submenu addItem:insertColorMenuItem];
	}
	
  [kUSRDEFS  boolForKey:kOMColorHelperHighlightingDisabled] ?:
    [self activateColorHighlighting];
}

#pragma mark - Preferences

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {


	if (menuItem.action == @selector(insertColor:)) {
		NSResponder *firstResponder = [NSApp keyWindow].firstResponder;
		return [firstResponder isKindOfClass:NSClassFromString(@"DVTSourceTextView")] &&
           [firstResponder isKindOfClass:NSTextView.class];

  } else if (menuItem.action == @selector(toggleColorHighlightingEnabled:)) {

    BOOL enabled = [kUSRDEFS  boolForKey:kOMColorHelperHighlightingDisabled];
		return [menuItem setState:enabled ? NSOffState : NSOnState], YES;

	} else if (menuItem.action == @selector(selectNSColorInsertionMode:)) {

		menuItem.state = [kUSRDEFS  integerForKey:kOMColorHelperInsertionMode] == 1
                   ? NSOnState : NSOffState;

	} else if (menuItem.action == @selector(selectUIColorInsertionMode:)) {

    menuItem.state = ![kUSRDEFS  integerForKey:kOMColorHelperInsertionMode]
                   ? NSOnState : NSOffState;
	}
	return YES;
}

- (void)selectNSColorInsertionMode:_ {


	[kUSRDEFS setInteger:1 forKey:kOMColorHelperInsertionMode];
}

- (void)selectUIColorInsertionMode:_ {


	[kUSRDEFS  setInteger:0 forKey:kOMColorHelperInsertionMode];
}

- (void)toggleColorHighlightingEnabled:_ {


	BOOL enabled = [kUSRDEFS  boolForKey:kOMColorHelperHighlightingDisabled];
	[kUSRDEFS  setBool:!enabled forKey:kOMColorHelperHighlightingDisabled];

  enabled ? [self activateColorHighlighting] : [self deactivateColorHighlighting];
}

- (void)activateColorHighlighting {


	[kNCENTER addObserver:self selector:@selector(selectionDidChange:) name:NSTextViewDidChangeSelectionNotification object:nil];
	if (!self.textView) {
		NSResponder *firstResponder = [[NSApp keyWindow] firstResponder];
		if ([firstResponder isKindOfClass:NSClassFromString(@"DVTSourceTextView")] && [firstResponder isKindOfClass:[NSTextView class]]) {
			self.textView = (NSTextView *)firstResponder;
		}
	}
	if (self.textView)
    [self selectionDidChange:[NSNotification notificationWithName:NSTextViewDidChangeSelectionNotification
                                                           object:self.textView]];
}

- (void)deactivateColorHighlighting {


	[kNCENTER removeObserver:self name:NSTextViewDidChangeSelectionNotification object:nil];
	[self dismissColorWell];
	//self.textView = nil;
}

#pragma mark - Color Insertion

- (void)insertColor:(id)sender {


	if (!self.textView) {
		NSResponder *firstResponder = [[NSApp keyWindow] firstResponder];
		if ([firstResponder isKindOfClass:NSClassFromString(@"DVTSourceTextView")] && [firstResponder isKindOfClass:[NSTextView class]]) {
			self.textView = (NSTextView *)firstResponder;
		} else {
			NSBeep();
			return;
		}
	}
	if ([kUSRDEFS  boolForKey:kOMColorHelperHighlightingDisabled]) {
		//Inserting a color implicitly activates color highlighting:
		[kUSRDEFS  setBool:NO forKey:kOMColorHelperHighlightingDisabled];
		[self activateColorHighlighting];
	}
	[self.textView.undoManager beginUndoGrouping];
	NSInteger insertionMode = [kUSRDEFS  integerForKey:kOMColorHelperInsertionMode];
	if (insertionMode == 0) {
		[self.textView insertText:@"[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]" replacementRange:self.textView.selectedRange];
	} else {
		[self.textView insertText:@"[NSColor colorWithCalibratedRed:1.0 green:0.0 blue:0.0 alpha:1.0]" replacementRange:self.textView.selectedRange];
	}
	[self.textView.undoManager endUndoGrouping];
	[self performSelector:@selector(activateColorWell) withObject:nil afterDelay:0.0];
}

- (void)activateColorWell {


	[self.colorWell activate:YES];
}

#pragma mark - Text Selection Handling

- (void)selectionDidChange:(NSNotification *)notification {


	if ([[notification object] isKindOfClass:NSClassFromString(@"DVTSourceTextView")] && [[notification object] isKindOfClass:[NSTextView class]]) {
		self.textView = (NSTextView *)[notification object];
		
		BOOL disabled = [kUSRDEFS  boolForKey:kOMColorHelperHighlightingDisabled];
		if (disabled) return;
		
		NSArray *selectedRanges = [self.textView selectedRanges];
		if (selectedRanges.count >= 1) {

      NSRange selectedRange       = [selectedRanges[0] rangeValue];
      NSString *text              = self.textView.textStorage.string;
      NSRange lineRange           = [text lineRangeForRange:selectedRange];
      NSRange selectedRangeInLine = NSMakeRange(selectedRange.location - lineRange.location, selectedRange.length);
      NSString *line              = [text substringWithRange:lineRange];

      NSRange colorRange          = NSMakeRange(NSNotFound, 0);
      OMColorType colorType       = OMColorTypeNone;
      NSColor *matchedColor       = [self colorInText:line      selectedRange:selectedRangeInLine
                                                 type:&colorType matchedRange:&colorRange];
			if (matchedColor) {

        NSColor *backgroundColor     = [self.textView.backgroundColor colorUsingColorSpace:NSColorSpace.genericRGBColorSpace];

        CGFloat r = 1, g = 1, b = 1;  [backgroundColor getRed:&r green:&g blue:&b alpha:NULL];

        CGFloat backgroundLuminance  = (r + g + b) / 3.0;

        NSColor *strokeColor         = (backgroundLuminance > 0.5) ? [NSColor colorWithCalibratedWhite:.2 alpha:1]
                                                                   : NSColor.whiteColor;

        self.selectedColorType       = colorType;
        self.colorWell.color         = matchedColor;
        self.colorWell.strokeColor   = strokeColor;

        self.selectedColorRange = NSMakeRange(colorRange.location + lineRange.location, colorRange.length);
        NSRect selectRectOnScrn = [self.textView firstRectForCharacterRange:self.selectedColorRange],
                selectRectInWin = [self.textView.window convertRectFromScreen:selectRectOnScrn],
               selectRectInView = [self.textView convertRect:selectRectInWin fromView:nil],
                  colorWellRect = NSMakeRect(NSMaxX(selectRectInView) - 49,
                                             NSMinY(selectRectInView) - selectRectInView.size.height - 2,
                                             50,    selectRectInView.size.height + 2);
        self.colorWell.frame      = NSIntegralRect(colorWellRect);
        [self.textView addSubview:self.colorWell];
        self.colorFrameView.frame = NSInsetRect(NSIntegralRect(selectRectInView), -1, -1);
        self.colorFrameView.color = strokeColor;

				[self.textView addSubview:self.colorFrameView];

      } else [self dismissColorWell];
		} else [self dismissColorWell];
	}
}

- (void)dismissColorWell {


	if (self.colorWell.isActive) {
		[self.colorWell deactivate];
		[NSColorPanel.sharedColorPanel orderOut:nil];
	}
	[self.colorWell      removeFromSuperview];
	[self.colorFrameView removeFromSuperview];
	self.selectedColorRange = NSMakeRange(NSNotFound, 0);
	self.selectedColorType  = OMColorTypeNone;
}

- (void)colorDidChange:_ {

	if (self.selectedColorRange.location == NSNotFound) return;

	NSString *colorString = [self colorStringForColor:self.colorWell.color withType:self.selectedColorType];
	if (!colorString) return;

  [self.textView.undoManager beginUndoGrouping];
  [self.textView insertText:colorString replacementRange:self.selectedColorRange];
  [self.textView.undoManager   endUndoGrouping];
}

#pragma mark - View Initialization

- (OMPlainColorWell *)colorWell {


	if (!_colorWell) {
		_colorWell = [[OMPlainColorWell alloc] initWithFrame:NSMakeRect(0, 0, 50, 30)];
		[_colorWell setTarget:self];
		[_colorWell setAction:@selector(colorDidChange:)];
	}
	return _colorWell;
}

- (OMColorFrameView *)colorFrameView {


	if (!_colorFrameView) {
		_colorFrameView = [[OMColorFrameView alloc] initWithFrame:NSZeroRect];
	}
	return _colorFrameView;
}

#pragma mark - Color String Parsing

- (NSColor *)colorInText:(NSString *)text   selectedRange:(NSRange)selectedRange
                    type:(OMColorType *)type matchedRange:(NSRangePointer)matchedRange {


	__block NSColor *foundColor = nil;
	__block NSRange foundColorRange = NSMakeRange(NSNotFound, 0);
	__block OMColorType foundColorType = OMColorTypeNone;
	
	[_rgbaUIColorRegex enumerateMatchesInString:text options:0 range:NSMakeRange(0, text.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		NSRange colorRange = [result range];
		if (selectedRange.location >= colorRange.location && NSMaxRange(selectedRange) <= NSMaxRange(colorRange)) {

      NSString *typeIndicator = [text substringWithRange:[result rangeAtIndex:1]];

      foundColorType = [typeIndicator rangeOfString:@"init"].location != NSNotFound ? OMColorTypeUIRGBAInit
                                                                                    : OMColorTypeUIRGBA;
			
			// [UIColor colorWithRed:128 / 255.0 green:10 / 255 blue:123/255 alpha:128 /255]
			
			double red = [text substringWithRange:[result rangeAtIndex:2]].doubleValue;
             red = [self dividedValue:red withDivisorRange:[result rangeAtIndex:3] inString:text];
			
			double green = [text substringWithRange:[result rangeAtIndex:4]].doubleValue;
             green = [self dividedValue:green withDivisorRange:[result rangeAtIndex:5] inString:text];
			
			double blue = [text substringWithRange:[result rangeAtIndex:6]].doubleValue;
             blue = [self dividedValue:blue withDivisorRange:[result rangeAtIndex:7] inString:text];
			
			double alpha = [text substringWithRange:[result rangeAtIndex:8]].doubleValue;
			       alpha = [self dividedValue:alpha withDivisorRange:[result rangeAtIndex:9] inString:text];
			
			foundColor = [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:alpha];
			foundColorRange = colorRange;
			*stop = YES;
		}
	}];
	
	if (!foundColor) {

		[_whiteUIColorRegex enumerateMatchesInString:text options:0 range:NSMakeRange(0, text.length)
                                     usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags _, BOOL *stop) {

      NSRange colorRange = result.range;
			if (selectedRange.location < colorRange.location || NSMaxRange(selectedRange) > NSMaxRange(colorRange))
        return;

      NSString *typeIndicator = [text substringWithRange:[result rangeAtIndex:1]];
      foundColorType = [typeIndicator rangeOfString:@"init"].location != NSNotFound ? OMColorTypeUIWhiteInit
                                                                                    : OMColorTypeUIWhite;

      double white = [[text substringWithRange:[result rangeAtIndex:2]] doubleValue];
             white = [self dividedValue:white withDivisorRange:[result rangeAtIndex:3] inString:text];
      
      double alpha = [[text substringWithRange:[result rangeAtIndex:4]] doubleValue];
             alpha = [self dividedValue:alpha withDivisorRange:[result rangeAtIndex:5] inString:text];
      
        foundColor = [NSColor colorWithCalibratedWhite:white alpha:alpha];

      foundColorRange = colorRange; *stop = YES;

		}];
	}
	
	if (!foundColor) {

		[_constantColorRegex enumerateMatchesInString:text options:0 range:NSMakeRange(0, text.length)
                                       usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags _, BOOL *stop) {

      NSRange colorRange = result.range;
			if (selectedRange.location < colorRange.location || NSMaxRange(selectedRange) > NSMaxRange(colorRange))
        return;

      NSString *NS_UI     = [text substringWithRange:[result rangeAtIndex:1]];
      NSString *colorName = [text substringWithRange:[result rangeAtIndex:2]];
               foundColor = _constantColorsByName[colorName];
          foundColorRange = colorRange;
      foundColorType = [NS_UI isEqualToString:@"UI"] ? OMColorTypeUIConstant
                                                     : OMColorTypeNSConstant; *stop = YES;
		}];
	}
	
	if (!foundColor) {

		[_rgbaNSColorRegex enumerateMatchesInString:text options:0 range:NSMakeRange(0, text.length)
                                    usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags _, BOOL *stop) {

      NSRange colorRange = result.range;

      if (selectedRange.location < colorRange.location || NSMaxRange(selectedRange) > NSMaxRange(colorRange))
        return;
      NSString *deviceOrCalibrated = [text substringWithRange:[result rangeAtIndex:1]];
      if ([deviceOrCalibrated isEqualToString:@"Device"]) {
        foundColorType = OMColorTypeNSRGBADevice;
      } else {
        foundColorType = OMColorTypeNSRGBACalibrated;
      }
      double   red = [text substringWithRange:[result rangeAtIndex:2]].doubleValue;
               red = [self dividedValue:red withDivisorRange:[result rangeAtIndex:3] inString:text];
      
      double green = [text substringWithRange:[result rangeAtIndex:4]].doubleValue;
             green = [self dividedValue:green withDivisorRange:[result rangeAtIndex:5] inString:text];
      
      double  blue = [text substringWithRange:[result rangeAtIndex:6]].doubleValue;
              blue = [self dividedValue:blue withDivisorRange:[result rangeAtIndex:7] inString:text];
      
      double alpha = [text substringWithRange:[result rangeAtIndex:8]].doubleValue;
             alpha = [self dividedValue:alpha withDivisorRange:[result rangeAtIndex:9] inString:text];
      
      foundColor = foundColorType == OMColorTypeNSRGBACalibrated ?
        [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:alpha] :
        [NSColor colorWithDeviceRed:red     green:green blue:blue alpha:alpha] ;

      foundColorRange = colorRange; *stop = YES;
		}];
	}
	
	if (!foundColor) {

		[_whiteNSColorRegex enumerateMatchesInString:text options:0 range:NSMakeRange(0, text.length)
                                      usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags _, BOOL *stop) {

      NSRange colorRange = result.range;

			if (selectedRange.location < colorRange.location || NSMaxRange(selectedRange) > NSMaxRange(colorRange))
        return;

      NSString *deviceOrCalibrated = [text substringWithRange:[result rangeAtIndex:1]];
      double white = [text substringWithRange:[result rangeAtIndex:2]].doubleValue;
             white = [self dividedValue:white withDivisorRange:[result rangeAtIndex:3] inString:text];
      
      double alpha = [text substringWithRange:[result rangeAtIndex:4]].doubleValue;
             alpha = [self dividedValue:alpha withDivisorRange:[result rangeAtIndex:5] inString:text];
      
      if ([deviceOrCalibrated isEqualToString:@"Device"]) {
        foundColor     = [NSColor colorWithDeviceWhite:white alpha:alpha];
        foundColorType = OMColorTypeNSWhiteDevice;
      } else {
        foundColor     = [NSColor colorWithCalibratedWhite:white alpha:alpha];
        foundColorType = OMColorTypeNSWhiteCalibrated;
      }
      foundColorRange = colorRange; *stop = YES;
		}];
	}
	
	if (!foundColor) return nil;

  if (matchedRange != NULL) *matchedRange = foundColorRange;
  if (type         != NULL) *type         = foundColorType;

  return foundColor;
}

- (double)dividedValue:(double)value withDivisorRange:(NSRange)divisorRange inString:(NSString *)text {


	if (divisorRange.location != NSNotFound) {
		double divisor = [[[text substringWithRange:divisorRange] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/ "]] doubleValue];
		if (divisor != 0) {
			value /= divisor;
		}
	}
	return value;
}

- (NSString *)colorStringForColor:(NSColor *)color withType:(OMColorType)colorType {


	NSString *colorString = nil;
	CGFloat r = -1.0; CGFloat g = -1.0; CGFloat b = -1.0; CGFloat a = -1.0;
	color = [color colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
	[color getRed:&r green:&g blue:&b alpha:&a];
		
	if (r< 0) return colorString;

  for (NSString *colorName in _constantColorsByName) {

    NSColor *constantColor = _constantColorsByName[colorName];
    if ([constantColor isEqual:color]) {

      colorString = OMColorTypeIsNSColor(colorType) ? [NSString stringWithFormat:@"[NSColor %@Color]", colorName]
                                                  : [NSString stringWithFormat:@"[UIColor %@Color]", colorName];
      break;
    }
  }

    return colorString ?: fabs(r - g) < 0.001 && fabs(g - b) < 0.001  ?

      colorType == OMColorTypeUIRGBA            ||
      colorType == OMColorTypeUIWhite           ||
      colorType == OMColorTypeUIConstant
    ? [NSString stringWithFormat:@"[UIColor colorWithWhite:%.3f alpha:%.3f]",r,a]
    : colorType == OMColorTypeUIRGBAInit        ||
      colorType == OMColorTypeUIWhiteInit
    ? [NSString stringWithFormat:@"[[UIColor alloc] initWithWhite:%.3f alpha:%.3f]",r,a]
    : colorType == OMColorTypeNSConstant        ||
      colorType == OMColorTypeNSRGBACalibrated  ||
      colorType == OMColorTypeNSWhiteCalibrated
    ? [NSString stringWithFormat:@"[NSColor colorWithCalibratedWhite:%.3f alpha:%.3f]",r,a]
    : colorType == OMColorTypeNSRGBADevice      ||
      colorType == OMColorTypeNSWhiteDevice
    ? [NSString stringWithFormat:@"[NSColor colorWithDeviceWhite:%.3f alpha:%.3f]",r,a]
    : colorType == OMColorTypeUIRGBA            ||
      colorType == OMColorTypeUIWhite           ||
      colorType == OMColorTypeUIConstant
    ? [NSString stringWithFormat:@"[UIColor colorWithRed:%.3f green:%.3f blue:%.3f alpha:%.3f]",r,g,b,a]
    : colorType == OMColorTypeUIRGBAInit        ||
      colorType == OMColorTypeUIWhiteInit
    ? [NSString stringWithFormat:@"[[UIColor alloc] initWithRed:%.3f green:%.3f blue:%.3f alpha:%.3f]",r,g,b,a]
    : colorType == OMColorTypeNSConstant        ||
      colorType == OMColorTypeNSRGBACalibrated  ||
      colorType == OMColorTypeNSWhiteCalibrated
    ? [NSString stringWithFormat:@"[NSColor colorWithCalibratedRed:%.3f green:%.3f blue:%.3f alpha:%.3f]",r,g,b,a]
    : colorType == OMColorTypeNSRGBADevice      ||
      colorType == OMColorTypeNSWhiteDevice
    ? [NSString stringWithFormat:@"[NSColor colorWithDeviceRed:%.3f green:%.3f blue:%.3f alpha:%.3f]",r,g,b,a]
    : colorString : colorString;
}

- (void)dealloc {	[kNCENTER removeObserver:self]; }

@end
