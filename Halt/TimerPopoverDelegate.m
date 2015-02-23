//
//  TimerPopoverDelegate.m
//  Halt
//
//  Created by Kanari on 15/2/20.
//  Copyright (c) 2015年 Kanari. All rights reserved.
//

#import "TimerPopoverDelegate.h"
#import "TimerPopoverViewController.h"
#import "TimerLogic.h"

@class TimerInfo;

@implementation TimerPopoverDelegate

@synthesize popover;

- (id)init {
	if (self = [super init]) {
		viewController = [[TimerPopoverViewController alloc] initWithNibName:@"TimerPopoverView" bundle:[NSBundle mainBundle]];
		detachWindow.contentView = viewController.view;
	}
	return self;
}

- (void)showPopover:(id)sender timerInfo:(TimerInfo *)timerInfo{
	if (popover == nil) {
		popover = [NSPopover new];
		popover.appearance = [NSAppearance appearanceNamed:@"NSAppearanceNameVibrantLight"];
		popover.delegate = self;
		popover.contentViewController = viewController;
		popover.behavior = NSPopoverBehaviorTransient;
	}
	viewController.timerInfo = timerInfo;
	[popover showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxYEdge];
}

- (void)popoverDidClose:(NSNotification *)notification {
	popover = nil;
}

- (NSWindow *)detachableWindowForPopover:(NSPopover *)popover {
	return detachWindow;
}

- (BOOL)popoverShouldDetach:(NSPopover *)popover {
	return YES;
}

@end
