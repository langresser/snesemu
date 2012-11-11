//
//  LMSaveManager.m
//  SiOS
//
//  Created by Lucas Menge on 1/18/12.
//  Copyright (c) 2012 Lucas Menge. All rights reserved.
//

#import "LMSaveManager.h"

#import "SNES9X/port.h"
#import "SNES9X/snes9x.h"
#import "SNES9X/snapshot.h"

#import "SNES9XBridge/iOSAudio.h"

extern "C" volatile int SI_EmulationDidPause;
extern "C" volatile int SI_AudioIsOnHold;

@implementation LMSaveManager(Privates)
+ (void)LM_saveStateForROMName:(NSString*)rom inSlot:(int)slot
{
  NSLog(@"EmulationDidPause %i", SI_EmulationDidPause);
  NSLog(@"AudioIsOnHold %i", SI_AudioIsOnHold);
  
  NSString* savePath = [LMSaveManager pathForSaveOfROMName:rom slot:slot];
  
  if(S9xFreezeGame([savePath UTF8String]))
    NSLog(@"Saved to %@", savePath);
  else
    NSLog(@"Failed to save to %@", savePath);
}

+ (void)LM_loadStateForROMName:(NSString*)rom inSlot:(int)slot
{
  NSLog(@"EmulationDidPause %i", SI_EmulationDidPause);
  NSLog(@"AudioIsOnHold %i", SI_AudioIsOnHold);
  
  NSString* savePath = [LMSaveManager pathForSaveOfROMName:rom slot:slot];
  
  if([[NSFileManager defaultManager] fileExistsAtPath:savePath] == NO)
  {
    NSLog(@"Save file doesn't exist at: %@", savePath);
    return;
  }
  
  if(S9xUnfreezeGame([savePath UTF8String]))
    NSLog(@"Loaded from %@", savePath);
  else
    NSLog(@"Failed to load from %@", savePath);
}

@end

LMSaveManager* g_saveManager = nil;

@implementation LMSaveManager
@synthesize currentRomName, currentSaveSlot;
+(LMSaveManager*)sharedInstance
{
    if (g_saveManager == nil) {
        g_saveManager = [[LMSaveManager alloc]init];
    }
    
    return g_saveManager;
}

+ (NSString*)pathForSaveOfROMName:(NSString*)rom slot:(int)slot
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* saveFolderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"saves"];
  
    if([[NSFileManager defaultManager] fileExistsAtPath:saveFolderPath isDirectory:nil] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:saveFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
  
  NSString* romFileNameWithoutExtension = [[rom lastPathComponent]stringByDeletingPathExtension];
  NSString* saveFileName = [[romFileNameWithoutExtension stringByAppendingPathExtension:[NSString stringWithFormat:@"%03d", slot]] stringByAppendingPathExtension:@"frz"];
  return [saveFolderPath stringByAppendingPathComponent:saveFileName];
}

+ (BOOL)hasStateForROMNamed:(NSString*)rom slot:(int)slot
{
  NSString* path = [LMSaveManager pathForSaveOfROMName:rom slot:slot];
  return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (void)saveStateForROMNamed:(NSString*)rom slot:(int)slot
{ 
  [LMSaveManager LM_saveStateForROMName:rom inSlot:slot];
}
+ (void)loadStateForROMNamed:(NSString*)rom slot:(int)slot
{ 
  [LMSaveManager LM_loadStateForROMName:rom inSlot:slot];
}

@end
