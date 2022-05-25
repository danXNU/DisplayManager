//
//  SuperAgent.m
//  GHDisplayManager
//
//  Created by Daniel Bazzani on 24/05/22.
//

#import "SuperAgent.h"
#import "DisplayManager.h"

@implementation SuperAgent

-(NSUUID *)getUUIDFromDisplayID:(CGDirectDisplayID)displayID {
    CFUUIDRef _uuid = CGDisplayCreateUUIDFromDisplayID(displayID);
    NSString *uuidStr = (__bridge NSString *)CFUUIDCreateString(NULL, _uuid);
    return [[NSUUID alloc] initWithUUIDString:uuidStr];
}

- (NSArray *)getCurrentConfig {
    const int displayCount = 3;
    CGDirectDisplayID ids[displayCount] = {};
    uint32_t actCount = 0;
    CGError error = CGGetOnlineDisplayList(displayCount, ids, &actCount);
    NSLog(@"🔴 CGGetOnlineDisplayList error: %d", error);

    NSMutableArray *objects = [NSMutableArray array];

    for (int i=0; i<actCount; i++) {
        CGRect bounds = CGDisplayBounds(ids[i]);
        printf("Bounds of display %d: x(%f) y(%f)   width: %f  height: %f\n", ids[i], bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
        NSDictionary *obj = @{
            @"id": @(ids[i]),
            @"rect": @{ @"x": @(bounds.origin.x), @"y": @(bounds.origin.y), @"width": @(bounds.size.width), @"height": @(bounds.size.height) },
            @"isMain": (CGMainDisplayID() == ids[i] ? @1 : @0)
        };
        [objects addObject: obj];
    }

    return objects;
}

-(BOOL)applyConfig:(NSArray *)config {

    CGDisplayConfigRef dspTransaction = NULL;
    CGError res = CGBeginDisplayConfiguration(&dspTransaction);
    if (res != kCGErrorSuccess) {
        printf("Error starting config: %d", res);
        return NO;
    }
    
    DisplayManager *manager = [[DisplayManager alloc] init];
    NSArray<NSNumber *> *displaysIDs = [manager getActiveMonitors];
    NSMutableDictionary *displays = [[NSMutableDictionary alloc] initWithDictionary:@{}];
    
    for (NSNumber *display in displaysIDs) {
        NSUUID *uuid = [manager getUUIDFromDisplayNumber:display];
        displays[uuid] = display;
    }
    
    for (NSDictionary *display in config) {
        NSUUID *disUUID = ((NSUUID *)display[@"id"]);
        CGDirectDisplayID dispID = [displays[disUUID] unsignedIntValue];
        
        float x = [display[@"rect"][@"x"] floatValue];
        float y = [display[@"rect"][@"y"] floatValue];
        CGError originRes = CGConfigureDisplayOrigin(dspTransaction, dispID, x, y); // config, displayID, x, y
    }
    
    CGError res2 = CGCompleteDisplayConfiguration(dspTransaction, kCGConfigureForSession);
    return YES;
}

@end
