//
//  AppDelegate.h
//  Halt
//
//  Created by Kanari on 15/2/20.
//  Copyright (c) 2015年 Kanari. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TimerPopoverDelegate.h"
#import "TimerInfo.h"
#import "RHStatusItemView.h"
#import "PreferenceController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate> {
	TimerPopoverDelegate *popoverDelegate;
	TimerInfo *timerInfo;
	NSMenuItem *turnOffMenuItem, *turnOnMenuItem;
	
	PreferenceController *preferenceController;
	NSWindow *blockWindow;
//	BOOL runOnStart;
}

@property (weak) IBOutlet NSMenu *menu;
@property NSStatusItem *statusItem;
@property RHStatusItemView *statusView;

- (IBAction)turnOffClicked:(id)sender;
- (IBAction)turnOnClicked:(id)sender;
- (IBAction)openPreferences:(id)sender;

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification;
- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification;

@end

