//
//  TimerPopoverViewController.h
//  Halt
//
//  Created by Kanari on 15/2/21.
//  Copyright (c) 2015年 Kanari. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TimerInfo.h"

@interface TimerPopoverViewController : NSViewController {
	NSTimer *refreshTimer;
}

@property (weak) IBOutlet NSButton *haltButton;
@property (weak) IBOutlet NSTextField *postponeLabel;
@property (weak) IBOutlet NSTextField *timeLabel;
@property (weak) IBOutlet NSTextField *untilLabel;
@property (weak) TimerInfo *timerInfo;

@end
