//
//  SNES4iPadAppDelegate.m
//  SNES4iPad
//
//  Created by Yusef Napora on 5/10/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "SNES4iOSAppDelegate.h"

#import "EmulationViewController.h"
#import "UMFeedback.h"
#import "MobClick.h"
#include "Snes9xMain.h"

SNES4iOSAppDelegate *AppDelegate()
{
	return (SNES4iOSAppDelegate *)[[UIApplication sharedApplication] delegate];
}

@implementation SNES4iOSAppDelegate
#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSDictionary *firstRunValues = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithBool:YES], USER_DEFAULT_KEY_AUTOSAVE,
									[NSNumber numberWithBool:YES], USER_DEFAULT_KEY_SMOOTH_SCALING,
                                    [NSNumber numberWithBool:YES],
                                    USER_DEFAULT_KEY_SOUND,
									nil];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	for (NSString *defaultKey in [firstRunValues allKeys])
	{
		NSNumber *value = [defaults objectForKey:defaultKey];
		if (!value)
		{
			value = [firstRunValues objectForKey:defaultKey];
			[defaults setObject:value forKey:defaultKey];
		}
	}
    
    gameListVC = [[GameListViewController alloc]init];

    [MobClick startWithAppkey:kUMengAppKey];
    [[DianJinOfferPlatform defaultPlatform] setAppId:kDianjinAppKey andSetAppKey:kDianjinAppSecrect];
	[[DianJinOfferPlatform defaultPlatform] setOfferViewColor:kDJBrownColor];
    [UMFeedback checkWithAppkey:kUMengAppKey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRecNewMsg:) name:UMFBCheckFinishedNotification object:nil];

    gameVC = [[UINavigationController alloc] initWithRootViewController:gameListVC];
    [gameVC setNavigationBarHidden:YES];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = gameVC;
//    [self.window addSubview:emulationViewController.view];
//    emulationViewController.view.hidden = YES;
    // 注意顺序 window不为key则presendViewController等函数无效
    [self.window makeKeyAndVisible];    
    
    return YES;
}

-(void)applicationDidEnterBackground:(UIApplication *)application
{
    SISetEmulationPaused(1);
    SIWaitForPause();
}

-(void)applicationWillEnterForeground:(UIApplication *)application
{
    SISetEmulationPaused(0);
}

-(void)showSettingPopup:(BOOL)show
{
    if (show) {
        if (isPad()) {
            if (popoverVC == nil) {
                settingVC = [[SettingViewController alloc]initWithNibName:nil bundle:nil];
                popoverVC = [[UIPopoverController alloc] initWithContentViewController:settingVC];
                popoverVC.delegate = self;
            }
            
            CGRect rect;
            switch (gameVC.interfaceOrientation) {
                case UIInterfaceOrientationLandscapeLeft:
                case UIInterfaceOrientationLandscapeRight:
                    rect = CGRectMake(100, 60, 10, 10);
                    [popoverVC presentPopoverFromRect:rect inView:gameVC.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
                    break;
                case UIInterfaceOrientationPortrait:
                case UIInterfaceOrientationPortraitUpsideDown:
                    rect = CGRectMake(400, 580, 10, 10);
                    [popoverVC presentPopoverFromRect:rect inView:gameVC.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
                    break;
                default:
                    break;
            }
            
        } else {
            if (settingVC == nil) {
                settingVC = [[SettingViewController alloc]initWithNibName:nil bundle:nil];
            }
            
            [gameVC pushViewController:settingVC animated:YES];
        }
    } else {
        if (isPad()) {
            [popoverVC dismissPopoverAnimated:YES];
        } else {
            [settingVC.navigationController popViewControllerAnimated:YES];
        }
    }
    
}

-(void)showGameList
{
    if (isPad()) {
        [popoverVC dismissPopoverAnimated:NO];
    }

    SISetEmulationRunning(0);
    SIWaitForEmulationEnd();
    [gameVC popToRootViewControllerAnimated:YES];
}

-(void)restartGame
{
    if (isPad()) {
        [popoverVC dismissPopoverAnimated:NO];
    }
    
    SISetEmulationRunning(0);
    SIWaitForEmulationEnd();
    [gameVC popToRootViewControllerAnimated:NO];
    [gameListVC restartGame];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
}

-(void)onRecNewMsg:(NSNotification*)notification
{
    NSArray * newReplies = [notification.userInfo objectForKey:@"newReplies"];
    if (!newReplies) {
        return;
    }
    
    UIAlertView *alertView;
    NSString *title = [NSString stringWithFormat:@"有%d条新回复", [newReplies count]];
    NSMutableString *content = [NSMutableString string];
    for (int i = 0; i < [newReplies count]; i++) {
        NSString * dateTime = [[newReplies objectAtIndex:i] objectForKey:@"datetime"];
        NSString *_content = [[newReplies objectAtIndex:i] objectForKey:@"content"];
        [content appendString:[NSString stringWithFormat:@"%d: %@---%@\n", i+1, _content, dateTime]];
    }
    
    alertView = [[UIAlertView alloc] initWithTitle:title message:content delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    ((UILabel *) [[alertView subviews] objectAtIndex:1]).textAlignment = NSTextAlignmentLeft ;
    [alertView show];
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Save data if appropriate
}
@end

