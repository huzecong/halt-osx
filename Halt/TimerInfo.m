//
//  TimerInfo.m
//  Halt
//
//  Created by Kanari on 15/2/21.
//  Copyright (c) 2015年 Kanari. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TimerInfo.h"
#import "TimerLogic.h"

@interface TimerInfo ()

@property int postponeCount;
@property enum InfoStatus status;

@end

@implementation TimerInfo

@synthesize runTime, postponeLimit, postponeTime, haltTime, postponeCount;

- (id)init {
	if (self = [super init]) {
		
	}
	return self;
}

- (id)initWithAction:(SEL)action target:(id)target {
	if (self = [super init]) {
		// Load defaults
		NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
		runTime = [userDefault floatForKey:@"runTime"];
		postponeTime = [userDefault floatForKey:@"postponeTime"];
		haltTime = [userDefault floatForKey:@"haltTime"];
		postponeLimit = (int)[userDefault integerForKey:@"postponeLimit"];
		
		// Initialize timer logic
		NSMethodSignature *ms = [target methodSignatureForSelector:action];
		NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:ms];
		[invocation setTarget:target];
		[invocation setSelector:action];
		timer = [[TimerLogic alloc] initWithInvokeAction:invocation];
	}
	return self;
}

- (NSTimeInterval)remainingTime {
	return timer.remainingTime;
}

- (NSString *)localizedTime:(NSTimeInterval)_time {
	int time = (int)ceil(_time);
	int hour = time / 3600, minute = time / 60 % 60, second = time % 60;
	NSString *hourPart, *minutePart, *secondPart;
	if (hour == 0) hourPart = @"";
	else if (hour == 1) hourPart = NSLocalizedString(@" hour", @"localize time single hour");
	else hourPart = NSLocalizedString(@" hours", @"localize time plural hour");
	if (minute == 0) minutePart = @"";
	else if (minute == 1) minutePart = NSLocalizedString(@" minute", @"localize time single minute");
	else minutePart = NSLocalizedString(@" minutes", @"localize time plural minute");
	if (second == 0) secondPart = @"";
	else if (second == 1) secondPart = NSLocalizedString(@" second", @"localize time single second");
	else secondPart = NSLocalizedString(@" seconds", @"localize time plural second");

	NSString *ret = @"";
	if (hour > 0) ret = [NSString stringWithFormat:@"%@ %d%@", ret, hour, hourPart];
	if (minute > 0) ret = [NSString stringWithFormat:@"%@ %d%@", ret, minute, minutePart];
	if (second > 0) ret = [NSString stringWithFormat:@"%@ %d%@", ret, second, secondPart];
	return [ret substringFromIndex:1];
}

- (NSString *)localizedPostponeCount {
	NSString *times;
	if (postponeCount == 1) {
		times = NSLocalizedString(@"once", @"display postpone label count");
	} else if (postponeCount == 2) {
		times = NSLocalizedString(@"twice", @"display postpone label count");
	} else {
		times = [NSString stringWithFormat:NSLocalizedString(@"%@ times", @"display postpone label count"), [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithInt:postponeCount] numberStyle:NSNumberFormatterSpellOutStyle]];
	}
	return times;
}

- (void)run {
	if (timer.status == TimerRunning) {
		[timer stopTimer];
	}
	self.status = InfoRunning;
	postponeCount = 0;
	[timer setTimeInterval:runTime];
	[timer startTimer];
}

- (BOOL)postpone {
	if (postponeCount >= postponeLimit) {
		return NO;
	}
	if (timer.status == TimerRunning) {
		[timer stopTimer];
	}
	self.status = InfoPostponed;
	++postponeCount;
	[timer setTimeInterval:postponeTime];
	[timer startTimer];
	return YES;
}

- (void)halt {
	if (timer.status == TimerRunning) {
		[timer stopTimer];
	}
	self.status = InfoHalting;
	[timer setTimeInterval:haltTime];
	[timer startTimer];
}

- (void)off {
	if (timer.status == TimerRunning) {
		[timer stopTimer];
	}
	self.status = InfoOff;
	postponeCount = 0;
}

@end
