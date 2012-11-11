//
//  LMPixelView.h
//  SiOS
//
//  Created by Lucas Menge on 1/2/12.
//  Copyright (c) 2012 Lucas Menge. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "SIScreenDelegate.h"

@interface LMPixelView : UIView<SIScreenDelegate>
{
    unsigned int _bufferWidth;
    unsigned int _bufferHeight;
    unsigned int _bufferHeightExtended;
    unsigned char* _imageBuffer;
    unsigned char* _imageBufferAlt;
    unsigned char* _565ImageBuffer;
}

-(void)viewDidShow;
- (void)flipFrontbuffer;
@end
