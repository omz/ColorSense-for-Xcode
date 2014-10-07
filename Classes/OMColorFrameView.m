
//  OMColorFrameView.m OMColorHelper   Created by Ole Zorn on 09/07/12.

#import "OMColorFrameView.h"

@implementation OMColorFrameView

- (void)drawRect:(NSRect)_ {

	[self.color setStroke]; 	[NSBezierPath strokeRect:NSInsetRect(self.bounds, 0.5, 0.5)];
}

- (void)setColor:(NSColor *)color
{
	if (color == _color) return; _color = color; [self setNeedsDisplay:YES];
}


@end
