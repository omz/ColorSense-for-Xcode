//
//  OMColorFrameView.h
//  OMColorHelper
//
//  Created by Ole Zorn on 09/07/12.
//
//

#import <Cocoa/Cocoa.h>

@interface OMColorFrameView : NSView {

	NSColor *_color;
}

@property (nonatomic, strong) NSColor *color;

@end
