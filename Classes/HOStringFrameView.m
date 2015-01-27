//
//  HOStringSense by Dirk Holtwick 2012, holtwick.it
//  Based on OMColorSense by by Ole Zorn, 2012
//  Licensed under BSD style license
//

#import "HOStringFrameView.h"

@implementation HOStringFrameView

- (void)drawRect:(NSRect)dirtyRect
{
	[self.color setStroke];
	NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(self.bounds, 0.5, 0.5) xRadius:3.0 yRadius:3.0];
	[path stroke];
}

- (void)setColor:(NSColor *)color
{
	if (color != _color) {
		_color = color;
		[self setNeedsDisplay:YES];
	}
}


@end
