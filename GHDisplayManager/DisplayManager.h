//
//  DisplayManager.h
//  GHDisplayManager
//
//  Created by Daniel Fortesque on 27/04/21.
//

#import <Foundation/Foundation.h>
#import "test.h"

NS_ASSUME_NONNULL_BEGIN

@interface DisplayManager : NSObject
- (CGSDisplayMode)getModeFromDisplayNumber:(CGDirectDisplayID)display;
- (NSArray<NSNumber *> *)getActiveMonitors;
- (void)saveCurrentConfig;
- (NSDictionary *)loadSavedConfig;
- (void)applyConfig:(NSDictionary *)configMap;
- (NSUUID *)getUUIDFromDisplayNumber:(NSNumber *)displayNumber;
- (NSArray<NSDictionary *> *)getModesForMonitor:(NSUUID *)displayID;
@end

NS_ASSUME_NONNULL_END
