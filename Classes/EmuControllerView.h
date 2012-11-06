#import <UIKit/UIKit.h>

#import <Foundation/Foundation.h>
#import <QuartzCore/CALayer.h>
#import "DView.h"
#import "AnalogStick.h"
#import "ScreenView.h"

#import <pthread.h>
#import <sched.h>
#import <unistd.h>
#import <sys/time.h>

#define NUM_BUTTONS 10

@interface EmuControllerView : UIView
{
  ScreenView		* screenView;
  UIImageView	    * imageBack;
  UIImageView	    * imageOverlay;
  DView             * dview;

  UIImageView	    * dpadView;
  UIImageView	    * buttonViews[NUM_BUTTONS];

  AnalogStickView   * analogStickView;

  //joy controller
  CGRect ButtonUp;
  CGRect ButtonLeft;
  CGRect ButtonDown;
  CGRect ButtonRight;
  CGRect ButtonUpLeft;
  CGRect ButtonDownLeft;
  CGRect ButtonUpRight;
  CGRect ButtonDownRight;
  CGRect Up;
  CGRect Left;
  CGRect Down;
  CGRect Right;
  CGRect UpLeft;
  CGRect DownLeft;
  CGRect UpRight;
  CGRect DownRight;
  CGRect Select;
  CGRect Start;
  CGRect LPad;
  CGRect RPad;
  CGRect LPad2;
  CGRect RPad2;
  CGRect Menu;

  //buttons & Dpad images
  CGRect rDPad_image;
  NSString *nameImgDPad[9];

  CGRect rButton_image[NUM_BUTTONS];

  NSString *nameImgButton_Press[NUM_BUTTONS];
  NSString *nameImgButton_NotPress[NUM_BUTTONS];
}

@property(nonatomic, retain) ScreenView* screenView;

- (void)getControllerCoords:(int)orientation;

- (void)getConf;
- (void)filldrectsController;

- (void)removeDPadView;
- (void)buildDPadView;

- (void)changeUI : (UIInterfaceOrientation)interfaceOrientation;

- (void)buildPortrait;
- (void)buildLandscape;

- (void)handle_DPAD;
@end
