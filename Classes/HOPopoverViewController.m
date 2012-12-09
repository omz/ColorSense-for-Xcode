//
//  Copyright 2012 Dirk Holtwick, holtwick.it. All rights reserved.
//

#import "HOPopoverViewController.h"

@implementation HOPopoverViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (NSView *)view {
    NSTextField *textfield = [[[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 200)] autorelease];
    [super setView:textfield];
    return [super view];
}

@end
