//
//  SISaveDelegate.m
//  SiOS
//
//  Created by Lucas Menge on 1/19/12.
//  Copyright (c) 2012 Lucas Menge. All rights reserved.
//

#import "SISaveDelegate.h"


static NSObject<SISaveDelegate>* delegate = nil;

void SISetSaveDelegate(id<SISaveDelegate> value)
{
  delegate = value;
}

#pragma mark - Start and End Notifications

void SILoadRunningStateForGameNamed(const char* romFileName)
{
  @autoreleasepool {
      [delegate loadROMRunningState];
  }
}
   
void SISaveRunningStateForGameNamed(const char* romFileName)
{
  @autoreleasepool {
      [delegate saveROMRunningState];
  }
}
