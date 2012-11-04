    //
//  EmulationViewController.m
//  SNES4iPad
//
//  Created by Yusef Napora on 5/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SNES4iOSAppDelegate.h"
#import "EmulationViewController.h"
#import "ScreenView.h"
#import "SNESControllerViewController.h"
#import "ScreenLayer.h"
#import <QuartzCore/QuartzCore.h>

#define kSavedState @"savedState"

#define RADIANS(degrees) ((degrees * M_PI) / 180.0)
#define DEGREES(radians) (radians * 180.0/M_PI)

volatile int __emulation_run;
volatile int __emulation_saving;
volatile int __emulation_paused;
volatile int __emulation_reset;

extern int iphone_main(char *filename);

// C wrapper function for emulation core access
void refreshScreenSurface()
{
	[AppDelegate().emulationViewController performSelectorOnMainThread:@selector(refreshScreen) withObject:nil waitUntilDone:NO];
}

// entry point for emulator thread
void *threadedStart(NSString *completeFilePath)
{
	@autoreleasepool {
        void *romName = (void *)[[completeFilePath lastPathComponent] UTF8String];
        void *completeUTF8StringFilePath = (void*)[completeFilePath UTF8String];
		char *filename = malloc(strlen((char *)completeUTF8StringFilePath) + 1);
        strcpy(filename, (char *)romName);
		printf("Starting emulator for %s\n", filename);
		__emulation_run = 1;
#if !TARGET_IPHONE_SIMULATOR
		iphone_main(filename);
#endif
		__emulation_run = 0;
		__emulation_saving = 0;
		
        free(filename);
	}
    
    return 0;
}

void convertBufferToARGB(unsigned int *dest, unsigned short *source, int w, int h)
{
    int x, y;
    // convert to ARGB
    for (y=0; y < h; y++) {
        for (x=0; x < w; x++) {
            unsigned int index = (y*w)+x;
            unsigned short source_pixel = source[index];  
            unsigned char r = (source_pixel & 0xf800) >> 11;
            unsigned char g = (source_pixel & 0x07c0) >> 5;
            unsigned char b = (source_pixel & 0x003f);
            dest[index] = 0xff000000 | 
                                      (((r << 3) | (r >> 2)) << 16) | 
                                      (((g << 2) | (g >> 4)) << 8)  | 
                                      ((b << 3) | (b >> 2));
        }
    }
    
}

// helper function to save a snapshot of the current framebuffer contents
void saveScreenshotToFile(char *filepath)
{
#if !TARGET_IPHONE_SIMULATOR
    NSLog(@"writing screenshot to %s", filepath);
    int width = 256;
    int height = 224;
    
    unsigned int *argb_buffer = (unsigned int *)malloc(width * height * 4);
    extern unsigned short *vrambuffer;  // this holds the 256x224 framebuffer in L565 format
    convertBufferToARGB(argb_buffer, vrambuffer, width, height);
    
    // make data provider from buffer
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, argb_buffer, (width * height * 4), NULL);

    // set up for CGImage creation
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * width;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Little |  kCGImageAlphaNoneSkipFirst;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef imageRef = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);

    UIImage *uiImage = [[UIImage alloc] initWithCGImage:imageRef];
	
	NSData *pngData = UIImagePNGRepresentation(uiImage);
	[pngData writeToFile:[NSString stringWithCString:filepath encoding:NSUTF8StringEncoding] atomically:YES];
	
	CGImageRelease(imageRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(provider);
    free(argb_buffer);
#endif
}

@implementation EmulationViewController

@synthesize pauseAlert;
- (void)loadView {
	self.view = (UIView *)[[ScreenView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if (ControllerAppDelegate().controllerType == SNESControllerTypeLocal) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self didRotate:[NSNotification notificationWithName:@"RotateNotification" object:nil]];
}

- (void) refreshScreen
{
    [self.view setNeedsDisplay];
}

- (void) startWithRom:(NSString *)romFile
{
   
    dispatch_queue_t dispatchQueue = dispatch_queue_create("EmulationThread", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(dispatchQueue, ^{
        NSLog(@"RomFile Path:%@", romFile);
        threadedStart(romFile);
    });
    dispatch_release(dispatchQueue);
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
                interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    }
    else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}

- (void) setLandscapeRight {
    AppDelegate().snesControllerViewController.view.backgroundColor = [UIColor blackColor];
    AppDelegate().snesControllerViewController.view.transform = CGAffineTransformIdentity;
    AppDelegate().snesControllerViewController.view.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(180.0));
    
    ScreenLayer *layer = (ScreenLayer *)self.view.layer;
    layer.anchorPoint = CGPointMake(0.0, 0.0);
    layer.rotateTransform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(90.0));
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.view.bounds = CGRectMake(0, 0, 360, 317);
        self.view.frame = CGRectMake(319, 60, 317, 360);//320, 480
    } else {
        AppDelegate().snesControllerViewController.imageView.hidden = YES;
        self.view.bounds = CGRectMake(0, 0, 872, 763);
        self.view.frame = CGRectMake(766, 76, 763, 872);//768, 1024
    }
    
    //AppDelegate().snesControllerViewController.sustainButton.center = CGPointMake(24, 456);
}

- (void) setLandscapeLeft {
    AppDelegate().snesControllerViewController.view.backgroundColor = [UIColor blackColor];
    AppDelegate().snesControllerViewController.view.transform = CGAffineTransformIdentity;
    AppDelegate().snesControllerViewController.view.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(0.0));
    
    ScreenLayer *layer = (ScreenLayer *)self.view.layer;
    layer.anchorPoint = CGPointMake(0.0, 0.0);
    layer.rotateTransform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(90.0));
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.view.bounds = CGRectMake(0, 0, 256, 224);
        self.view.frame = CGRectMake(272, 112, 224, 256);//320, 480
    } else {
        AppDelegate().snesControllerViewController.imageView.hidden = YES;
        self.view.bounds = CGRectMake(0, 0, 512, 448);
        self.view.frame = CGRectMake(608, 256, 448, 512);//768, 1024
    }
    
    //AppDelegate().snesControllerViewController.sustainButton.center = CGPointMake(24, 456);
}

- (void) didRotate:(NSNotification *)notification {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if ((orientation == UIDeviceOrientationPortrait ||
         orientation == UIDeviceOrientationLandscapeLeft ||
         orientation == UIDeviceOrientationLandscapeRight) &&
        ![(UIAlertView *)self.pauseAlert isVisible] &&
        self.view.superview != nil) { // &&
        //[[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        //These coordinates take into considerationt the fact that the UIWindow is in portrait mode
        if (orientation == UIDeviceOrientationPortrait) {
            //
        }
        else if (orientation == UIDeviceOrientationLandscapeLeft) {
            [self setLandscapeLeft];
        }
        else if (orientation == UIDeviceOrientationLandscapeRight) {
            [self setLandscapeRight];
        }
    }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	if (touch.tapCount == 2) {
        CGPoint touchPoint = [(UITouch *)touch locationInView:self.view];
        CGRect rect = CGRectMake(touchPoint.x, touchPoint.y, 60, 60);
		[self showPauseDialogFromRect:rect];
	}
}

- (void) showPauseDialogFromRect:(CGRect)rect {
    NSString *title = @"Select an option";
    NSString *destructiveButtonTitle = @"Quit Game";
    NSString *button1Title = @"Save State";
    NSString *button2Title = @"Save State to New File";
    NSString *button3Title = @"Reset";
    __emulation_paused = 1;
    //clearFramebuffer();
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.pauseAlert = (id)[[UIActionSheet alloc] initWithTitle:title
                                                           delegate:self
                                                  cancelButtonTitle:nil destructiveButtonTitle:destructiveButtonTitle
                                                  otherButtonTitles:button1Title, button2Title, button3Title, nil];
        
        [(UIActionSheet *)self.pauseAlert showFromRect:rect inView:self.view animated:YES];
    }
    else {
        //purposely leave title off
        self.pauseAlert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:nil 
                                                       delegate:self 
                                              cancelButtonTitle:destructiveButtonTitle 
                                              otherButtonTitles:button1Title, button2Title, button3Title, @"Cancel", nil];
        /*CGFloat rotation = DEGREES(atan2(self.view.superview.transform.b, self.view.superview.transform.a));
        CGFloat rotationAngle = 0.0;
        if (rotation >= -5 && rotation <= 5) {//Gives us a margin of error of 10, even though we shouldn't need it
            if (AppDelegate().snesControllerViewController.imageView.frame.size.height > 321) {
                rotationAngle = 90.0;
            }
        }
        else if (rotation >= 175 && rotation <= 185) {
            rotationAngle = 270.0;
        }
        alert.transform = CGAffineTransformRotate(CGAffineTransformIdentity, rotationAngle);*/
        [(UIAlertView *)self.pauseAlert show];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{	
	[self object:actionSheet clickedButtonAtIndex:buttonIndex];
	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self object:alertView clickedButtonAtIndex:buttonIndex];
}

- (void)object:(id)object clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSInteger quitIndex = 0;
    NSInteger saveCurrentIndex = 1;
	NSInteger saveNewIndex = 2;
	NSInteger resetIndex = 3;
	
	if (buttonIndex == quitIndex) {
        NSLog(@"Quit button clicked");
		__emulation_run = 0;
        [AppDelegate() showEmulator:NO];
	} else if (buttonIndex == saveCurrentIndex) {
		NSLog(@"save to current file button clicked");
		__emulation_saving = 2;
	} else if (buttonIndex == saveNewIndex) {
		NSLog(@"save to new file button clicked");
		__emulation_saving = 1;
	} else if (buttonIndex == resetIndex) {
		NSLog(@"reset button clicked");
		__emulation_reset = 1;
	}
    __emulation_paused = 0;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@end


