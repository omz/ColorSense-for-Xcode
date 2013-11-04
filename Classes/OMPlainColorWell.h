//
//  OMPlainColorWell.h
//  OMColorHelper
//
//  Created by Ole Zorn on 09/07/12.
//
//

#import <Cocoa/Cocoa.h>

@interface OMPlainColorWell : NSColorWell {

	NSColor *_strokeColor;
}

@property (nonatomic, strong) NSColor *strokeColor;

@end
