#import <UIKit/UIKit.h>

#import <Foundation/Foundation.h>
#import <QuartzCore/CALayer.h>
#import "DView.h"
#import "AnalogStick.h"

#import <pthread.h>
#import <sched.h>
#import <unistd.h>
#import <sys/time.h>

#define NUM_BUTTONS 10

@interface EmuControllerView : UIView
{

  UIView			* screenView;
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



- (void)getControllerCoords:(int)orientation;

- (void)getConf;
- (void)filldrectsController;

- (void)startEmulation;

- (void)removeDPadView;
- (void)buildDPadView;

- (void)changeUI;

- (void)buildPortraitImageBack;
- (void)buildPortraitImageOverlay;
- (void)buildPortrait;
- (void)buildLandscapeImageOverlay;
- (void)buildLandscapeImageBack;
- (void)buildLandscape;

- (void)handle_DPAD;

- (void)touchesController:(NSSet *)touches withEvent:(UIEvent *)event;
@end
