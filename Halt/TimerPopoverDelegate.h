//
//  TimerPopoverDelegate.h
//  Halt
//
//  Created by Kanari on 15/2/20.
//  Copyright (c) 2015年 Kanari. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "TimerPopoverViewController.h"

@class TimerLogic;
@class TimerInfo;

@interface TimerPopoverDelegate : NSObject <NSPopoverDelegate> {
@private
	IBOutlet NSPopover *popover;
	IBOutlet NSWindow *detachWindow;
	IBOutlet TimerPopoverViewController *viewController;
}

@property NSPopover *popover;

- (void)showPopover:(id)sender timerInfo:(TimerInfo *)timerInfo;

@end
