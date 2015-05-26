
//  OMColorFrameView.m OMColorHelper   Created by Ole Zorn on 09/07/12.

#import "OMColorViews.h"

@implementation OMColorFrameView

- (void)drawRect:(NSRect)_ {

	[self.color setStroke]; 	[NSBezierPath strokeRect:NSInsetRect(self.bounds, 0.5, 0.5)];
}

- (void)setColor:(NSColor *)color
{
	if (color == _color) return; _color = color; [self setNeedsDisplay:YES];
}

@end

@implementation OMPlainColorWell

- (void)drawRect:(NSRect)_ {

	[NSGraphicsContext saveGraphicsState];
  NSRect fillRect = NSMakeRect(0, -5, self.bounds.size.width, self.bounds.size.height + 5);
	NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:fillRect xRadius:5 yRadius:5];
	[path addClip];
	[self drawWellInside:self.bounds];
	[NSGraphicsContext restoreGraphicsState];
	
	if (!self.strokeColor) return;

  NSRect strokeRect = NSInsetRect(NSMakeRect(0, -5, self.bounds.size.width, self.bounds.size.height + 5),.5,.5);
  NSBezierPath *strokePath = [NSBezierPath bezierPathWithRoundedRect:strokeRect xRadius:5 yRadius:5];
  [self.strokeColor setStroke];
  [strokePath stroke];
}

- (void) deactivate { [super deactivate]; [NSColorPanel.sharedColorPanel orderOut:nil]; }

- (void)setStrokeColor:(NSColor *)strokeColor {

	if (strokeColor == _strokeColor) return; _strokeColor = strokeColor; [self setNeedsDisplay:YES];
}

@end

