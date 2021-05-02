//
//  DisplayManager.h
//  GHDisplayManager
//
//  Created by Daniel Fortesque on 27/04/21.
//

#import <Foundation/Foundation.h>
#import "CoreGraphicsAPI.h"
#import "Monitor.h"

NS_ASSUME_NONNULL_BEGIN

@interface DisplayManager : NSObject
- (CGSDisplayMode)getModeFromDisplayNumber:(CGDirectDisplayID)display;
- (NSArray<NSNumber *> *)getActiveMonitors;

- (void)applyConfig:(NSDictionary *)configMap;
- (NSUUID *)getUUIDFromDisplayNumber:(NSNumber *)displayNumber;
- (NSArray<NSDictionary *> *)getModesForMonitor:(NSUUID *)displayID;

- (NSDictionary *)loadSavedConfig;
- (NSDictionary *)loadSavedConfig:(NSString *)pathPassed;

- (void)saveCurrentConfig:(NSString *)pathPassed;
- (void)saveCurrentConfig;

- (void)applyMode:(NSUInteger)modeNumber toMonitorID:(NSUUID *)monitorID;

@end

NS_ASSUME_NONNULL_END
