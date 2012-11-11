//
//  EmulationViewController.h
//  SNES4iPad
//
//  Created by Yusef Napora on 5/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmuControllerView.h"
#import "iosUtil.h"

@interface EmulationViewController : UIViewController {
    id pauseAlert;
    UIInterfaceOrientation currentOrientation;

    EmuControllerView* controllerView;
    
    volatile NSThread* _emulationThread;
    
    NSString* _romFileName;
}

@property (strong, nonatomic) NSString* romFileName;
@end
