//
//  SuperObserver.m
//  GHDisplayManager
//
//  Created by Daniel Bazzani on 24/05/22.
//

#import "SuperObserver.h"

void callback(CGDirectDisplayID displayID, CGDisplayChangeSummaryFlags flags, void *userInfo) {
    //NSLog(@"FLAGS: %u", flags);
    NSDictionary *dict = @{ @"displayID": @(displayID), @"flags": @(flags) };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dm-callback" object:nil userInfo:dict];
    
//    if (flags & kCGDisplayAddFlag) {
//        CFUUIDRef _uuid = CGDisplayCreateUUIDFromDisplayID(displayID);
//        NSString *uuidStr = (__bridge NSString *)CFUUIDCreateString(NULL, _uuid);
//        NSLog(@"Connected display: %@", uuidStr);
//    }
}

@implementation SuperObserver

-(void)registerDisplayObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(somethingChanged:) name:@"dm-callback" object:nil];
    
    CGDisplayRegisterReconfigurationCallback(callback, NULL);
}

-(void)deactivateDisplayObserver {
    CGDisplayRemoveReconfigurationCallback(callback, NULL);
}

-(void)somethingChanged:(NSNotification *)notification {
    if ([self delegate]) {
        NSDictionary *userInfo = notification.userInfo;
        CGDirectDisplayID dispID = [(NSNumber *)userInfo[@"displayID"] unsignedIntValue];
        CGDisplayChangeSummaryFlags flags = (CGDisplayChangeSummaryFlags)[(NSNumber *)userInfo[@"flags"] unsignedIntValue];
        [self.delegate displayChanged:dispID flags:flags userInfo:NULL];
    }
}

@end
