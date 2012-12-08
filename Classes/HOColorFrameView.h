//
//  OMColorFrameView.h
//  OMColorHelper
//
//  Created by Ole Zorn on 09/07/12.
//
//

#import <Cocoa/Cocoa.h>

@interface HOColorFrameView : NSView {

	NSColor *_color;
}

@property (nonatomic, retain) NSColor *color;

@end
