//
//  LMSaveManager.h
//  SiOS
//
//  Created by Lucas Menge on 1/18/12.
//  Copyright (c) 2012 Lucas Menge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LMSaveManager : NSObject
{
    NSString* currentRomName;
    int currentSaveSlot;
}

+(LMSaveManager*)sharedInstance;

@property(nonatomic, strong) NSString* currentRomName;
@property(nonatomic, assign) int currentSaveSlot;

+ (NSString*)pathForSaveOfROMName:(NSString*)rom slot:(int)slot;
+ (BOOL)hasStateForROMNamed:(NSString*)rom slot:(int)slot;

+ (void)saveStateForROMNamed:(NSString*)rom slot:(int)slot;
+ (void)loadStateForROMNamed:(NSString*)rom slot:(int)slot;

@end
