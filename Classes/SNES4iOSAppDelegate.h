//
//  SNES4iPadAppDelegate.h
//  SNES4iPad
//
//  Created by Yusef Napora on 5/10/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmulationViewController.h"
#import "GameListViewController.h"
#import "SettingViewController.h"

#define kUMengAppKey @"509ad12152701560b9000001"
#define kDianjinAppKey 12519
#define kDianjinAppSecrect @"8c16476e3f10a98cbf8808161125f7b1"
#define kMangoAppKey @"0a6d56311af3494f8f3ce4e423269ab2"

@interface SNES4iOSAppDelegate : NSObject <UIApplicationDelegate, UIPopoverControllerDelegate> {
    
    UIWindow *window;
	
    UINavigationController* gameVC;
    GameListViewController* gameListVC;
    SettingViewController* settingVC;
    UIPopoverController * popoverVC;
}

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) UIPopoverController * popoverVC;

-(void)showSettingPopup:(BOOL)show;
-(void)showGameList;
-(void)restartGame;
@end

extern SNES4iOSAppDelegate *AppDelegate();