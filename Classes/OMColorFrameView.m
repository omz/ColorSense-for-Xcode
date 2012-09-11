//
//  OMColorFrameView.m
//  OMColorHelper
//
//  Created by Ole Zorn on 09/07/12.
//
//

#import "OMColorFrameView.h"

@implementation OMColorFrameView

@synthesize color=_color;

- (void)drawRect:(NSRect)dirtyRect
{
	[self.color setStroke];
    CGFloat dash[2] = { 2, 2 };
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSInsetRect(self.bounds, 0.5, 0.5)];
    [path setLineDash:dash count:2 phase:0];
    [path stroke];
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
