//
//  HOStringSense by Dirk Holtwick 2012, holtwick.it
//  Based on OMColorSense by by Ole Zorn, 2012
//  Licensed under BSD style license
//

#import "HOStringInfoButton.h"

@implementation HOStringInfoButton

- (id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        self.font = [NSFont boldSystemFontOfSize:11.];
        self.bordered = NO;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	[NSGraphicsContext saveGraphicsState];
	NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(0, 0, self.bounds.size.width, self.bounds.size.height ) xRadius:5.0 yRadius:5.0];
	[path addClip];

    [[NSColor colorWithCalibratedWhite:0.500 alpha:1.000] setFill];
    NSRectFill(self.bounds);
    [super drawRect:dirtyRect];

	// [self drawWellInside:self.bounds];
	[NSGraphicsContext restoreGraphicsState];

    if (self.strokeColor) {
        NSBezierPath *strokePath = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(NSMakeRect(0, 0, self.bounds.size.width, self.bounds.size.height), 0.5, 0.5) xRadius:5.0 yRadius:5.0];
        [self.strokeColor setStroke];
        [strokePath stroke];
    }
}

- (void)setStrokeColor:(NSColor *)strokeColor {
	if (strokeColor != _strokeColor) {
		_strokeColor = strokeColor;
		[self setNeedsDisplay:YES];
	}
}


@end
