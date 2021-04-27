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
- (NSArray *)getActiveMonitors;
- (void)saveCurrentConfig;
- (void)loadSavedConfig;
@end

NS_ASSUME_NONNULL_END
