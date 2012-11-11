//
//  LMPixelView.m
//  SiOS
//
//  Created by Lucas Menge on 1/2/12.
//  Copyright (c) 2012 Lucas Menge. All rights reserved.
//

#import "LMPixelView.h"

#import "LMPixelLayer.h"
#include "Snes9xMain.h"
#import "SettingViewController.h"

@implementation LMPixelView

- (void)drawRect:(CGRect)rect
{
  // override this to allow the CALayer to be invalidated and thus displaying the actual layer contents
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if(self)
  {
      _bufferWidth = 256;
      _bufferHeight = 224;
      _bufferHeightExtended = 239*2; // we're using double the extended height because the screenshot loading writes black to a MUCH larger portion of data in the screen variable. Wondering if I should fix the SNES9X code...
      
      // RGBA888 format
      unsigned short defaultComponentCount = 4;
      unsigned short bufferBitsPerComponent = 8;
      unsigned int pixelSizeBytes = (_bufferWidth*bufferBitsPerComponent*defaultComponentCount)/8/_bufferWidth;
      if(pixelSizeBytes == 0)
          pixelSizeBytes = defaultComponentCount;
      unsigned int bufferBytesPerRow = _bufferWidth*pixelSizeBytes;
      CGBitmapInfo bufferBitmapInfo = kCGImageAlphaNoneSkipLast;
      
      // BGR 555 format (something weird)
      defaultComponentCount = 3;
      bufferBitsPerComponent = 5;
      pixelSizeBytes = 2;
      bufferBytesPerRow = _bufferWidth*pixelSizeBytes;
      bufferBitmapInfo = kCGImageAlphaNoneSkipFirst|kCGBitmapByteOrder16Little;
      
      if(_imageBuffer == nil)
      {
          _imageBuffer = (unsigned char*)calloc(_bufferWidth*_bufferHeightExtended, pixelSizeBytes);
      }
      if(_imageBufferAlt == nil)
      {
          _imageBufferAlt = (unsigned char*)calloc(_bufferWidth*_bufferHeightExtended, pixelSizeBytes);
      }
      if(_565ImageBuffer == nil)
          _565ImageBuffer = (unsigned char*)calloc(_bufferWidth*_bufferHeightExtended, 2);
      
      [(LMPixelLayer*)self.layer setImageBuffer:_imageBuffer
                                                width:_bufferWidth
                                               height:_bufferHeight
                                     bitsPerComponent:bufferBitsPerComponent
                                          bytesPerRow:bufferBytesPerRow
                                           bitmapInfo:bufferBitmapInfo];
      [(LMPixelLayer*)self.layer addAltImageBuffer:_imageBufferAlt];
      

      // init by default
      NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
      SISetSoundOn([defaults boolForKey:USER_DEFAULT_KEY_SOUND]);
      if([defaults boolForKey:USER_DEFAULT_KEY_SMOOTH_SCALING] == YES)
      {
          self.layer.minificationFilter = kCAFilterLinear;
          self.layer.magnificationFilter = kCAFilterLinear;
      }
      else
      {
          self.layer.minificationFilter = kCAFilterNearest;
          self.layer.magnificationFilter = kCAFilterNearest;
      }
      
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsChanged) name:@"SettingsChanged" object:nil];
      
      SISetScreenDelegate(self);
      SISetScreen(_imageBuffer);
  }
  return self;
}

- (void)settingsChanged
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if([defaults boolForKey:USER_DEFAULT_KEY_SMOOTH_SCALING] == YES)
    {
        self.layer.minificationFilter = kCAFilterLinear;
        self.layer.magnificationFilter = kCAFilterLinear;
    }
    else
    {
        self.layer.minificationFilter = kCAFilterNearest;
        self.layer.magnificationFilter = kCAFilterNearest;
    }
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    if(_imageBuffer != nil)
        free(_imageBuffer);
    _imageBuffer = nil;
    
    if(_imageBufferAlt != nil)
        free(_imageBufferAlt);
    _imageBufferAlt = nil;
    
    if(_565ImageBuffer != nil)
        free(_565ImageBuffer);
    _565ImageBuffer = nil;
}

+ (Class)layerClass
{
  return [LMPixelLayer class];
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    LMPixelLayer *layer = (LMPixelLayer *)self.layer;
    int width = frame.size.width > frame.size.height ? frame.size.width : frame.size.height;
    int height = frame.size.width > frame.size.height ? frame.size.height : frame.size.width;
    layer.bounds = CGRectMake(0, 0, width, height);
}

- (void)flipFrontbuffer
{
    if(_imageBuffer == nil || _565ImageBuffer == nil)
        return;
    
    // we use two framebuffers to avoid copy-on-write due to us using UIImage. Little memory overhead, no speed overhead at all compared to that nasty IOSurface and SDK-safe, to boot
    if(((LMPixelLayer*)self.layer).displayMainBuffer == YES)
    {
        SISetScreen(_imageBufferAlt);
        
        [self setNeedsDisplay];
        
        ((LMPixelLayer*)self.layer).displayMainBuffer = NO;
    }
    else
    {
        SISetScreen(_imageBuffer);
        
        [self setNeedsDisplay];
        
        ((LMPixelLayer*)self.layer).displayMainBuffer = YES;
    }
}

@end