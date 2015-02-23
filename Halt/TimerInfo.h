//
//  TimerInfo.h
//  Halt
//
//  Created by Kanari on 15/2/21.
//  Copyright (c) 2015年 Kanari. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TimerLogic;

@interface TimerInfo : NSObject <NSUserNotificationCenterDelegate> {
	TimerLogic *timer;
	int postponeCount;
}

enum InfoStatus {
	InfoRunning,
	InfoPostponed,
	InfoHalting,
	InfoOff
} ;
@property (readonly) enum InfoStatus status;
@property NSTimeInterval runTime;
@property NSTimeInterval haltTime;
@property NSTimeInterval postponeTime;
@property int postponeLimit;
@property (readonly) NSTimeInterval remainingTime;
@property (readonly) int postponeCount;

- (id)initWithAction:(SEL)newAction target:(id)target;
- (void)run;
- (BOOL)postpone;
- (void)halt;
- (void)off;
- (NSString *)localizedPostponeCount;
- (NSString *)localizedTime:(NSTimeInterval)time;

@end
