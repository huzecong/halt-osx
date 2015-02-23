//
//  TimerPopoverViewController.m
//  Halt
//
//  Created by Kanari on 15/2/21.
//  Copyright (c) 2015年 Kanari. All rights reserved.
//

#import "TimerPopoverViewController.h"
#import "TimerInfo.h"

@interface TimerPopoverViewController ()

@end

@implementation TimerPopoverViewController

@synthesize untilLabel, timeLabel, postponeLabel, haltButton;
@synthesize timerInfo;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.

//	self.view.appearance = [NSAppearance appearanceNamed:@"NSAppearanceNameVibrantDark"];
	
	// Connect mouse event
	haltButton.action = @selector(click:);
	haltButton.target = self;
}

- (void)viewWillAppear {
	// Configure scheduled timer for refreshing information
	refreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateInfo) userInfo:nil repeats:YES];
}

- (void)viewDidDisappear {
	[refreshTimer invalidate];
	refreshTimer = nil;
}

- (NSString *)timeToString:(NSTimeInterval)_time {
	long time = (long)floor(_time);
	float diff = ceil(_time) - _time;
	if (0 <= diff && diff < 0.5) {
		return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", time / 3600, time / 60 % 60, time % 60];
	} else {
		return [NSString stringWithFormat:@"%02ld %02ld %02ld", time / 3600, time / 60 % 60, time % 60];
	}
}

- (void)updateInfo {
	[timeLabel setStringValue:[self timeToString:timerInfo.remainingTime]];
	if (timerInfo.status == InfoOff) {
		untilLabel.stringValue = NSLocalizedString(@"Not working...", @"display until label");
		postponeLabel.stringValue = @"";
		[haltButton setHidden:YES];
	} else {
		NSString *times = [timerInfo localizedPostponeCount];
		if (timerInfo.status == InfoHalting) {
			untilLabel.stringValue = NSLocalizedString(@"Until end of halt:", @"display until label");
			if (timerInfo.postponeCount > 0) {
				postponeLabel.stringValue = [NSString stringWithFormat:NSLocalizedString(@"Postponed %@ before halt", @"display postpone label"), times];
			} else {
				postponeLabel.stringValue = @"";
			}
			[haltButton setHidden:YES];
		} else {
			untilLabel.stringValue = NSLocalizedString(@"Until halt:", @"display until label");
			if (timerInfo.status == InfoPostponed) {
				postponeLabel.stringValue = [NSString stringWithFormat:NSLocalizedString(@"Already postponed %@", @"display postpone label"), times];
			} else {
				postponeLabel.stringValue = @"";
			}
			[haltButton setHidden:NO];
		}
	}
}

- (void)click:(id)sender {
	[timerInfo halt];
}

@end
