//
//  ScreenView.m
//  SNES4iPad
//
//  Created by Yusef Napora on 5/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "ScreenView.h"
#import "ScreenLayer.h"
#import "SettingsViewController.h"
#import "SNES4iOSAppDelegate.h"
#import "EmulationViewController.h"

@implementation ScreenView

#if !TARGET_IPHONE_SIMULATOR
+ (Class) layerClass
{
    return [ScreenLayer class];
}
#endif

- (id) initWithFrame:(CGRect)f
{
    if (self = [super initWithFrame:f])
    {
        NSLog(@"ScreenView init");
        self.clearsContextBeforeDrawing = NO;
        
//#if TARGET_IPHONE_SIMULATOR
        self.backgroundColor = [UIColor greenColor];
//#endif
    }
    return self;
}


// Wierd things happen without this empty drawRect
- (void)drawRect:(CGRect)rect {
   // [self update];
//    [self.layer display];
}


@end
