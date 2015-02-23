//
//  TimerLogic.m
//  SimpleTimer
//
//  Created by Kanari on 15/2/13.
//  Copyright (c) 2015年 Kanari. All rights reserved.
//

#import "TimerLogic.h"

@implementation TimerLogic

@synthesize invokeAction;
@synthesize timeInterval;

- (id)initWithInvokeAction:(NSInvocation *)invoke {
	if (self = [super init]) {
		invokeAction = invoke;
		self.timeElapsed = 0;
		self.status = TimerStopped;
	}
	return self;
}

- (NSDictionary *)timerUserInfo {
	return @{ @"startTime": [NSDate date] };
}

- (NSTimeInterval)remainingTime {
	if (self.status == TimerStopped) {
		return 0;
	} else if (self.status == TimerPaused) {
		return self.timeInterval - self.timeElapsed;
	} else {
		NSTimeInterval time = self.timeElapsed;
		NSDate *pauseTime = [self.timer userInfo][@"startTime"];
		time += [[NSDate date] timeIntervalSinceDate:pauseTime];
		return self.timeInterval - time;
	}
}

- (void)timerFired:(NSTimer *)timer {
//	NSDate *startDate = [timer userInfo][@"startTime"];
//	NSLog(@"Timer started on %@", startDate);
	self.timeElapsed = 0;
	self.status = TimerStopped;
	[self.invokeAction invoke];
}

- (void)startTimer {
	if (self.status == TimerStopped) {
		self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(timerFired:) userInfo:[self timerUserInfo] repeats:NO];
		self.status = TimerRunning;
	}
}

- (void)pauseTimer {
	if (self.status == TimerRunning) {
		NSDate *pauseTime = [self.timer userInfo][@"startTime"];
		self.timeElapsed += [[NSDate date] timeIntervalSinceDate:pauseTime];
		[self.timer invalidate];
		self.status = TimerPaused;
	}
}

- (void)resumeTimer {
	if (self.status == TimerPaused) {
		NSTimeInterval time = self.timeInterval - self.timeElapsed;
		self.timer = [NSTimer scheduledTimerWithTimeInterval:time
													  target:self
													selector:@selector(timerFired:)
													userInfo:[self timerUserInfo]
													 repeats:NO];
		self.status = TimerRunning;
	}
}

- (void)stopTimer {
	if (self.status != TimerStopped) {
		if (self.timer != nil) {
			[self.timer invalidate];
		}
		self.timeElapsed = 0;
		self.status = TimerStopped;
	}
}

@end
