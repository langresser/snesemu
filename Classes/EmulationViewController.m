    //
//  EmulationViewController.m
//  SNES4iPad
//
//  Created by Yusef Napora on 5/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SNES4iOSAppDelegate.h"
#import "EmulationViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "LMPixelLayer.h"
#import "LMPixelView.h"
#import "SNES9XBridge/Snes9xMain.h"
#import "SNES9XBridge/SISaveDelegate.h"
#import "LMSaveManager.h"

extern int g_rotation;

@implementation EmulationViewController
@synthesize romFileName = _romFileName;

- (void)loadView {
    CGRect rect = [UIScreen mainScreen].bounds;
    UIView* view = [[UIView alloc]initWithFrame:rect];
//    view.backgroundColor = [UIColor redColor];
    self.view = view;
    controllerView = [[EmuControllerView alloc]initWithFrame:rect];
    [self.view addSubview:controllerView];
   
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotateOrientation:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    
    currentOrientation = UIInterfaceOrientationLandscapeLeft;
    CGSize size = [UIScreen mainScreen].bounds.size;
    int width = size.width > size.height ? size.width : size.height;
    int height = size.width > size.height ? size.height : size.width;
    controllerView.frame = CGRectMake(0, 0, width, height);
    [controllerView changeUI:UIInterfaceOrientationLandscapeLeft];
    
    self.wantsFullScreenLayout = YES;
    self.view.multipleTouchEnabled = YES;
    
    g_rotation = [[NSUserDefaults standardUserDefaults]integerForKey:@"rotation"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];    
    
    [self startWithRom:_romFileName];
    SISetEmulationPaused(0);
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

    SISetEmulationPaused(1);
    SIWaitForPause();
}

-(void)dealloc
{
    SISetScreenDelegate(nil);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void) didRotateOrientation:(NSNotification *)notification {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == UIDeviceOrientationPortrait) {
        if (currentOrientation == UIInterfaceOrientationPortrait || !g_rotation) {
            return;
        }
        currentOrientation = UIInterfaceOrientationPortrait;
        CGSize size = [UIScreen mainScreen].bounds.size;
        int width = size.width < size.height ? size.width : size.height;
        int height = size.width < size.height ? size.height : size.width;
        controllerView.frame = CGRectMake(0, 0, width, height);
        [controllerView changeUI:UIInterfaceOrientationPortrait];
    } else if (orientation == UIDeviceOrientationPortraitUpsideDown) {
        if (currentOrientation == UIInterfaceOrientationPortraitUpsideDown || !g_rotation) {
            return;
        }
        currentOrientation = UIInterfaceOrientationPortraitUpsideDown;

        CGSize size = [UIScreen mainScreen].bounds.size;
        int width = size.width < size.height ? size.width : size.height;
        int height = size.width < size.height ? size.height : size.width;
        controllerView.frame = CGRectMake(0, 0, width, height);
        [controllerView changeUI:UIInterfaceOrientationPortraitUpsideDown];
    } else if (orientation == UIDeviceOrientationLandscapeLeft) {
        if (currentOrientation == UIInterfaceOrientationLandscapeRight || g_rotation) {
            return;
        }
        currentOrientation = UIInterfaceOrientationLandscapeRight;

        CGSize size = [UIScreen mainScreen].bounds.size;
        int width = size.width > size.height ? size.width : size.height;
        int height = size.width > size.height ? size.height : size.width;
        controllerView.frame = CGRectMake(0, 0, width, height);
        [controllerView changeUI:UIInterfaceOrientationLandscapeRight];
    } else if (orientation == UIDeviceOrientationLandscapeRight) {
        if (currentOrientation == UIInterfaceOrientationLandscapeLeft || g_rotation) {
            return;
        }
        currentOrientation = UIInterfaceOrientationLandscapeLeft;

        CGSize size = [UIScreen mainScreen].bounds.size;
        int width = size.width > size.height ? size.width : size.height;
        int height = size.width > size.height ? size.height : size.width;
        controllerView.frame = CGRectMake(0, 0, width, height);
        [controllerView changeUI:UIInterfaceOrientationLandscapeLeft];
    }
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)startWithRom:(NSString *)rom
{
    if(_emulationThread != nil) {
        return;
    }
    
    _emulationThread = [NSThread mainThread];
    [NSThread detachNewThreadSelector:@selector(emulationThreadMethod:) toTarget:self withObject:rom];
}

- (void)emulationThreadMethod:(NSString*)rom;
{
    if(_emulationThread == [NSThread mainThread])
        _emulationThread = [NSThread currentThread];
    
    const char* originalString = [rom UTF8String];
    char* romFileNameCString = (char*)calloc(strlen(originalString)+1, sizeof(char));
    strcpy(romFileNameCString, originalString);
    originalString = nil;
    
    SISetEmulationPaused(0);
    SISetEmulationRunning(1);
    SIStartWithROM(romFileNameCString);
    SISetEmulationRunning(0);
    
    free(romFileNameCString);
    
    if(_emulationThread == [NSThread currentThread])
        _emulationThread = nil;
}
@end


