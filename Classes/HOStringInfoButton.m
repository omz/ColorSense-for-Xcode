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
	NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(0, 0, self.bounds.size.width, self.bounds.size.height ) xRadius:3.0 yRadius:3.0];
	[path addClip];
	if (self.strokeColor) {
		[self.strokeColor set];
	}
	else {
		[[NSColor colorWithCalibratedWhite:0.500 alpha:0.500] setFill];
	}
	[path fill];
	[super drawRect:dirtyRect];

	// [self drawWellInside:self.bounds];
	[NSGraphicsContext restoreGraphicsState];
}

- (void)setStrokeColor:(NSColor *)strokeColor {
	if (strokeColor != _strokeColor) {
		_strokeColor = strokeColor;
		[self setNeedsDisplay:YES];
	}
}


@end
