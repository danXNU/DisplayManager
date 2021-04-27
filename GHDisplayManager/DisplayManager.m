//
//  DisplayManager.m
//  GHDisplayManager
//
//  Created by Daniel Fortesque on 27/04/21.
//

#import "DisplayManager.h"

@implementation DisplayManager

- (CGSDisplayMode)getModeFromDisplayNumber:(CGDirectDisplayID)display {
    int count;
  
    int currentMode;
    CGSGetCurrentDisplayMode(display, &currentMode);

    // ottengo il numero di modes disponibili
    CGSGetNumberOfDisplayModes(display, &count);


    //ottengo l'indice della modalità attuale
    CGSDisplayMode mode;
    CGSGetDisplayModeDescriptionOfLength(display, currentMode, &mode, sizeof(CGSDisplayMode));

    return mode;
}

-(NSArray *)getActiveMonitors {
    CGDirectDisplayID displaysIDs[3] = {};
    uint32_t displayCount = 0;

    //Ottengo la lista di ID dei monitor
    CGGetActiveDisplayList(3, displaysIDs, &displayCount);
    
    NSMutableArray<NSNumber *> *displays = [[NSMutableArray alloc] initWithCapacity:displayCount];
    for (int i = 0; i < displayCount; i++) {
        CGDirectDisplayID displayID = displaysIDs[i];
        NSNumber *displayNumber = [[NSNumber alloc] initWithInt:displayID];
        [displays addObject:displayNumber];
    }
    
    return displays;
}

- (NSUUID *)getUUIDFromDisplayNumber:(NSNumber *)displayNumber {
    CFUUIDRef _uuid = CGDisplayCreateUUIDFromDisplayID((CGDirectDisplayID)[displayNumber intValue]);
    NSString  *_uuidStr = (__bridge NSString *)CFUUIDCreateString(NULL, _uuid);
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:_uuidStr];
    return uuid;
}

- (void)saveCurrentConfig {
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    NSArray *activeMonitors = [self getActiveMonitors];
    
    for (NSNumber *displayNumber in activeMonitors) {
        NSUUID *displayID = [self getUUIDFromDisplayNumber:displayNumber];
        CGSDisplayMode mode = [self getModeFromDisplayNumber: displayNumber.intValue];
        
        NSNumber *modeNumber = [[NSNumber alloc] initWithUnsignedInt:mode.modeNumber];
        [map setObject:modeNumber forKey:[displayID UUIDString]];
    }
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:map options:NSJSONWritingPrettyPrinted error:&error];

    
    //--- solo per test
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@", str);
    // ----

    NSString *path = [[[NSFileManager defaultManager] currentDirectoryPath]  stringByAppendingString:@"/test.json"];
    NSLog(@"PATH: %@", path);
    
    [data writeToFile:path atomically:YES];
    
}

- (void)loadSavedConfig {
    NSString *path = [[[NSFileManager defaultManager] currentDirectoryPath]  stringByAppendingString:@"/test.json"];
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
    
    NSError *error;
    
    NSDictionary *map = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data
                                    options:NSJSONReadingAllowFragments
                                      error:&error];
    
    NSLog(@"%@", map);
}

@end
