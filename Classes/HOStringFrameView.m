//
//  HOStringSense by Dirk Holtwick 2012, holtwick.it
//  Based on OMColorSense by by Ole Zorn, 2012
//  Licensed under BSD style license
//

#import "HOStringFrameView.h"

@implementation HOStringFrameView

@synthesize color=_color;

- (void)drawRect:(NSRect)dirtyRect
{
	[self.color setStroke];
	[NSBezierPath strokeRect:NSInsetRect(self.bounds, 0.5, 0.5)];
}

- (void)setColor:(NSColor *)color
{
	if (color != _color) {
		[_color release];
		_color = [color retain];
		[self setNeedsDisplay:YES];
	}
}

- (void)dealloc
{
	[_color release];
	[super dealloc];
}

@end
