//
//  EmulationViewController.h
//  SNES4iPad
//
//  Created by Yusef Napora on 5/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmuControllerView.h"
#import "ScreenView.h"
#import "iosUtil.h"
#import "SettingViewController.h"
#import "GameListViewController.h"
#import "EmulationViewController.h"
#import "RomSelectionViewController.h"

@interface EmulationViewController : UIViewController <UIActionSheetDelegate, UIAlertViewDelegate, UIPopoverControllerDelegate> {
    id pauseAlert;

    EmuControllerView* controllerView;

    GameListViewController* gameListVC;
    SettingViewController* settingVC;
    UIPopoverController * popoverVC;
    
//    RomSelectionViewController* rsVC;
}

@property (strong, nonatomic) id pauseAlert;
@property (strong, nonatomic) UIPopoverController * popoverVC;

- (void) startWithRom:(NSString *)romFile;

- (void) refreshScreen;
- (void) didRotate:(NSNotification *)notification;

- (void) showPauseDialogFromRect:(CGRect)rect;
- (void) object:(id)object clickedButtonAtIndex:(NSInteger)buttonIndex;

-(void)showGameList;
@end
