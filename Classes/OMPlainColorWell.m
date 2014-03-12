//
//  OMPlainColorWell.m
//  OMColorHelper
//
//  Created by Ole Zorn on 09/07/12.
//
//

#import "OMPlainColorWell.h"

@implementation OMPlainColorWell

@synthesize strokeColor=_strokeColor;

- (void)drawRect:(NSRect)dirtyRect
{
	[NSGraphicsContext saveGraphicsState];
	NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(0, -5, self.bounds.size.width, self.bounds.size.height + 5) xRadius:5.0 yRadius:5.0];
	[path addClip];
	[self drawWellInside:self.bounds];
	[NSGraphicsContext restoreGraphicsState];
	
	if (self.strokeColor) {
		NSBezierPath *strokePath = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(NSMakeRect(0, -5, self.bounds.size.width, self.bounds.size.height + 5), 0.5, 0.5) xRadius:5.0 yRadius:5.0];
		[self.strokeColor setStroke];
		[strokePath stroke];
	}
}

- (void)deactivate
{
	[super deactivate];
	[[NSColorPanel sharedColorPanel] orderOut:nil];
}

- (void)setStrokeColor:(NSColor *)strokeColor
{
	if (strokeColor != _strokeColor) {
		_strokeColor = strokeColor;
		[self setNeedsDisplay:YES];
	}
}


@end
