//
//  Copyright 2012 Dirk Holtwick, holtwick.it. All rights reserved.
//

#import "HOStringInfoButton.h"

@implementation HOStringInfoButton

- (id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        self.title = @"open";
        self.bordered = NO;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[NSGraphicsContext saveGraphicsState];
	NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(0, -5, self.bounds.size.width, self.bounds.size.height + 5) xRadius:5.0 yRadius:5.0];
	[path addClip];

    {
        [[NSColor grayColor] setFill];
        NSRectFill(self.bounds);
        [super drawRect:dirtyRect];
    }

	// [self drawWellInside:self.bounds];
	[NSGraphicsContext restoreGraphicsState];
	
    //	if (self.strokeColor) {
    //		NSBezierPath *strokePath = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(NSMakeRect(0, -5, self.bounds.size.width, self.bounds.size.height + 5), 0.5, 0.5) xRadius:5.0 yRadius:5.0];
    //		[self.strokeColor setStroke];
    //		[strokePath stroke];
    //	}
}
//
//- (void)deactivate
//{
//	[super deactivate];
//	[[NSColorPanel sharedColorPanel] orderOut:nil];
//}
//
//- (void)setStrokeColor:(NSColor *)strokeColor
//{
//	if (strokeColor != _strokeColor) {
//		[_strokeColor release];
//		_strokeColor = [strokeColor retain];
//		[self setNeedsDisplay:YES];
//	}
//}
//
//- (void)dealloc
//{
//	[_strokeColor release];
//	[super dealloc];
//}

@end
