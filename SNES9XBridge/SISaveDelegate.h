//
//  SISaveDelegate.h
//  SiOS
//
//  Created by Lucas Menge on 1/19/12.
//  Copyright (c) 2012 Lucas Menge. All rights reserved.
//

// Delegate for the class that will handle save/load requests by the emulator
@protocol SISaveDelegate <NSObject>

- (void)loadROMRunningState;
- (void)saveROMRunningState;

@end

#pragma mark - Delegate Management Functions

// Sets who is the save/load delegate
void SISetSaveDelegate(id<SISaveDelegate> value);
