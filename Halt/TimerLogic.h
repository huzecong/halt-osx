//
//  TimerLogic.h
//  SimpleTimer
//
//  Created by Kanari on 15/2/13.
//  Copyright (c) 2015年 Kanari. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimerLogic : NSObject

enum TimerStatus {
	TimerStopped,
	TimerPaused,
	TimerRunning
};

@property enum TimerStatus status;
@property NSTimer *timer;
@property NSTimeInterval timeInterval, timeElapsed;
@property NSInvocation *invokeAction;

- (id)initWithInvokeAction:(NSInvocation *)invokeAction;
- (void)setTimeInterval:(NSTimeInterval)timeInterval;
- (void)startTimer;
- (void)pauseTimer;
- (void)resumeTimer;
- (void)stopTimer;
- (NSTimeInterval)remainingTime;

@end
