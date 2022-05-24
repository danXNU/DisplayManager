//
//  SuperAgent.h
//  GHDisplayManager
//
//  Created by Daniel Bazzani on 24/05/22.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <ApplicationServices/ApplicationServices.h>

@interface SuperAgent: NSObject

-(NSUUID *)getUUIDFromDisplayID:(CGDirectDisplayID)displayID;
-(NSArray *)getCurrentConfig;
-(BOOL)applyConfig:(NSArray *)config;

@end
