//
//  SuperObserver.h
//  GHDisplayManager
//
//  Created by Daniel Bazzani on 24/05/22.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <ApplicationServices/ApplicationServices.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SuperObserverDelegate <NSObject>
-(void)displayChanged:(CGDirectDisplayID)displayID flags:(CGDisplayChangeSummaryFlags)flags userInfo:(void* __nullable)userInfo;
@end

@interface SuperObserver : NSObject

@property(nonatomic, weak) id<SuperObserverDelegate> delegate;

-(void)registerDisplayObserver;
-(void)deactivateDisplayObserver;

@end

NS_ASSUME_NONNULL_END
