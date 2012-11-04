//
//  SettingView.m
//  MD
//
//  Created by 王 佳 on 12-8-20.
//  Copyright (c) 2012年 Gingco.Net New Media GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIDevice+Util.h"

MDGameViewController* g_delegate = nil;

@implementation MDGameViewController
@synthesize settingVC, popoverVC;
@synthesize gameListVC;

+(MDGameViewController*)sharedInstance
{
    if (g_delegate == nil) {
        g_delegate = [[MDGameViewController alloc]init];
    }
    
    return g_delegate;
}

-(void)showSettingPopup
{
    if (isPad()) {
        if (popoverVC == nil) {
            settingVC = [[SettingViewController alloc]initWithNibName:nil bundle:nil];
            popoverVC = [[UIPopoverController alloc] initWithContentViewController:settingVC];
            popoverVC.delegate = self;
        }
        
        CGRect rect;
        int x = 0;
        switch (x) {
            case 0:
                rect = CGRectMake(750, 60, 10, 10);
                break;
            case 270:
                rect = CGRectMake(0, 60, 10, 10);
                break;
            case 90:
                rect = CGRectMake(750, 960, 10, 10);
                break;
            default:
                rect = CGRectMake(750, 60, 10, 10);
                break;
        }
        [popoverVC presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    } else {
        if (settingVC == nil) {
            settingVC = [[SettingViewController alloc]initWithNibName:nil bundle:nil];
        }
        
        [self presentModalViewController:settingVC animated:YES];
    }
}

-(void)showGameList
{
    if (gameListVC == nil) {
        gameListVC = [[GameListViewController alloc]init];
    }
    
    [self presentModalViewController:gameListVC animated:NO];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
}
@end


void showSetting()
{
    [[MDGameViewController sharedInstance] showSettingPopup];
}
