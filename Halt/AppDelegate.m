//
//  AppDelegate.m
//  Halt
//
//  Created by Kanari on 15/2/20.
//  Copyright (c) 2015年 Kanari. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"
#import "TimerPopoverDelegate.h"
#import "TimerInfo.h"
#import "RHStatusItemView.h"

@interface AppDelegate () {
	CGFloat statusBarHeight;
	NSArray *nameArray, *toolTipArray;
	BOOL alwaysFrontmost;
}

@end

@implementation AppDelegate

@synthesize statusItem, statusView;
@synthesize menu;

#pragma mark - StatusItem and Related
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
	
	// Initialize constants and user defaults
	alwaysFrontmost = NO;
	nameArray = [NSArray arrayWithObjects:@"run_green", @"run_yellow", @"halt_red", @"off_grey", nil];
	toolTipArray = [NSArray arrayWithObjects:
				NSLocalizedString(@"Running!", @"status item tooltip - run"),
				NSLocalizedString(@"Halt postponed...", @"status item tooltip - postpone"),
				NSLocalizedString(@"Halt!", @"status item tooltip - halt"),
				NSLocalizedString(@"Not working...", @"status item tooltip - off"), nil];
	statusBarHeight = [[NSStatusBar systemStatusBar] thickness];
	[[NSUserDefaults standardUserDefaults] registerDefaults:
#ifdef DEBUG
		@{@"runTime": @5.0,
		  @"postponeTime": @2.0,
		  @"haltTime": @3.0,
		  @"postponeLimit": @4}];
#else
		@{@"runTime": @3600.0,
		  @"postponeTime": @600.0,
		  @"haltTime": @300.0,
		  @"postponeLimit": @4}];
#endif
	// Initialize status item right-click menu
	turnOffMenuItem = [[menu itemArray] objectAtIndex:0];
	turnOnMenuItem = [[menu itemArray] objectAtIndex:1];
	turnOffMenuItem.action = @selector(turnOffClicked:);
	turnOnMenuItem.action = @selector(turnOnClicked:);
//	((NSMenuItem *)[[menu itemArray] objectAtIndex:3]).action = @selector(openPreferences:);
	((NSMenuItem *)[[menu itemArray] objectAtIndex:5]).action = @selector(orderFrontStandardAboutPanel:);
	((NSMenuItem *)[[menu itemArray] objectAtIndex:6]).action = @selector(terminate:);
	[menu removeItem:turnOnMenuItem];
	// Create status bar item
	statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	statusView = [[RHStatusItemView alloc] initWithStatusBarItem:statusItem];
	statusItem.view = statusView;
	statusView.menu = menu;
	statusView.target = self;
	statusView.action = @selector(mouseClick:);
	// Initialize popover delegation
	popoverDelegate = [[TimerPopoverDelegate alloc] init];
	// Initialize block window
	blockWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 1366, 768) styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES];
	
	// Initialize timer and run
	timerInfo = [[TimerInfo alloc] initWithAction:@selector(timerFired:) target:self];
	[[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
	[[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
	[timerInfo addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
	[timerInfo off];
	
//	[timerInfo run];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"status"]) {
		enum InfoStatus status = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
		enum InfoStatus oldStatus = [[change objectForKey:NSKeyValueChangeOldKey] intValue];
		if (status == oldStatus) return ;
		[[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
		[self setStatusImageAndToolTip:status];
		if (status == InfoOff) {
			[menu removeItem:turnOffMenuItem];
			[menu insertItem:turnOnMenuItem atIndex:0];
		} else if (status == InfoHalting) {
			blockWindow.alphaValue = 0.5;
			[NSApp activateIgnoringOtherApps:YES];
			[blockWindow makeKeyAndOrderFront:self];
			alwaysFrontmost = YES;
		}
		if (oldStatus == InfoOff) {
			[menu removeItem:turnOnMenuItem];
			[menu insertItem:turnOffMenuItem atIndex:0];
		} else if (oldStatus == InfoHalting) {
			alwaysFrontmost = NO;
			[blockWindow orderOut:self];
		}
	}
}

- (void)applicationDidResignActive:(NSNotification *)notification {
	if (alwaysFrontmost) {
		[NSApp activateIgnoringOtherApps:YES];
		[blockWindow makeKeyAndOrderFront:self];
	}
}

- (void)setStatusImageAndToolTip:(enum InfoStatus)status {
	NSString *name = [nameArray objectAtIndex:status];
	NSString *toolTip = [toolTipArray objectAtIndex:status];
	NSImage *image = [NSImage imageNamed:name];
	CGFloat length = image.size.width / image.size.height * statusBarHeight * 0.8;
	[image setSize:NSMakeSize(length, statusBarHeight * 0.8)];
	statusView.image = image;
	statusView.alternateImage = image;
	[statusView.alternateImage setTemplate:YES];
	statusItem.length = length;
	statusView.toolTip = toolTip;
}

- (void)mouseClick:(id)sender {
	[popoverDelegate showPopover:sender timerInfo:timerInfo];
	[NSApp activateIgnoringOtherApps:YES];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
	[[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	NSAlert *alert = [[NSAlert alloc] init];
	alert.messageText = NSLocalizedString(@"Time's still ticking!", @"turn off alert title");
	alert.informativeText = NSLocalizedString(@"The timer of Halt is now running, and has to be reset when you turn on Halt for the next time. Are you sure you want to quit?", @"quit alert content");
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert addButtonWithTitle:NSLocalizedString(@"No", @"no button")];
	[alert addButtonWithTitle:NSLocalizedString(@"Yes", @"yes button")];
	NSModalResponse response = [alert runModal];
	if (response == NSAlertSecondButtonReturn) {
		return NSTerminateNow;
	} else {
		return NSTerminateCancel;
	}
}

#pragma mark - Timer Fired

- (void)timerFired:(NSTimer *)timer {
	NSUserNotification *notification = [NSUserNotification new];
	NSString *type = @"";
	
	notification.hasActionButton = YES;
	if (timerInfo.status == InfoRunning) {
		notification.title = NSLocalizedString(@"Halt!(title)", @"fire notification title - run/postpone");
		notification.informativeText = [NSString stringWithFormat:NSLocalizedString(@"You've worked continuously for %@, now it's time to halt and take a break", @"fire notification content - run/postpone"), [timerInfo localizedTime:timerInfo.runTime]];
		notification.actionButtonTitle = NSLocalizedString(@"Postpone(buttonTitle)", @"action button title - run/postpone");
		notification.otherButtonTitle = NSLocalizedString(@"Halt(buttonTitle)", @"action button title - run/postpone");
//		notification.additionalActions = [NSArray arrayWithObject:[NSUserNotificationAction actionWithIdentifier:@"halt" title:NSLocalizedString(@"Halt(buttonTitle)", @"action button title - run/postpone")]];
		type = @"run";
	} else if (timerInfo.status == InfoPostponed) {
		notification.title = NSLocalizedString(@"Halt!(title)", @"fire notification title - run/postpone");
		notification.subtitle = [NSString stringWithFormat:NSLocalizedString(@"Already postponed %@", @"fire notification subtitle"), [timerInfo localizedPostponeCount]];
		if (timerInfo.postponeCount >= timerInfo.postponeLimit) {
			notification.subtitle = [NSString stringWithFormat:@"%@ - %@", notification.subtitle, NSLocalizedString(@"no more postpones allowed", @"fire notification subtitle 2")];
			notification.otherButtonTitle = NSLocalizedString(@"Halt(buttonTitle)", @"action button title - run/postpone");
			notification.hasActionButton = NO;
			type = @"postpone no more";
		} else {
			notification.actionButtonTitle = NSLocalizedString(@"Postpone(buttonTitle)", @"action button title - run/postpone");
			notification.otherButtonTitle = NSLocalizedString(@"Halt(buttonTitle)", @"action button title - run/postpone");
//			notification.additionalActions = [NSArray arrayWithObject:[NSUserNotificationAction actionWithIdentifier:@"halt" title:NSLocalizedString(@"Halt(buttonTitle)", @"action button title - run/postpone")]];
			type = @"postpone";
		}
		notification.informativeText = [NSString stringWithFormat:NSLocalizedString(@"You've worked continuously for %@, now it's time to halt and take a break", @"fire notification content - run/postpone"), [timerInfo localizedTime:timerInfo.runTime + timerInfo.postponeCount * timerInfo.postponeTime]];
	} else if (timerInfo.status == InfoHalting) {
		notification.title = NSLocalizedString(@"Back to work", @"timer fire notification title - halt");
		notification.informativeText = NSLocalizedString(@"Halt time is up, you can now return to work... If you want", @"fire notification content - halt");
		notification.actionButtonTitle = NSLocalizedString(@"Turn off(buttonTitle)", @"action button title - halt");
		notification.otherButtonTitle = NSLocalizedString(@"Run(buttonTitle)", @"action button title - halt");
//		notification.additionalActions = [NSArray arrayWithObject:[NSUserNotificationAction actionWithIdentifier:@"halt" title:NSLocalizedString(@"Run(buttonTitle)", @"action button title - halt")]];
		type = @"halt";
	}
	
	notification.identifier = [NSString stringWithFormat:@"com.Kanari.Halt.TimeUpNotification time:%@", [[NSDate date] description]];
	notification.soundName = @"Glass.aiff";
	notification.userInfo = @{ @"Type": type };
	[[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
	[[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

- (void)handleNotification:(NSUserNotification *)notification {
	static NSString *lastIdentifier = @"";
	if ([notification.identifier isEqualTo:lastIdentifier]) return ;
	lastIdentifier = [notification.identifier copy];
	NSString *type = notification.userInfo[@"Type"];
	NSUserNotificationActivationType activationType = notification.activationType;
	if (activationType == NSUserNotificationActivationTypeActionButtonClicked || activationType == NSUserNotificationActivationTypeContentsClicked) {
		if ([type isEqualToString:@"run"]) {
			[timerInfo postpone];
		} else if ([type isEqualToString:@"postpone"]) {
			[timerInfo postpone];
		} else if ([type isEqualToString:@"postpone no more"]) {
			[timerInfo halt];
		} else if ([type isEqualToString:@"halt"]) {
			[timerInfo off];
		}
	} else if (activationType == NSUserNotificationActivationTypeNone) {
		if ([type isEqualToString:@"run"]) {
			[timerInfo halt];
		} else if ([type isEqualToString:@"postpone"]) {
			[timerInfo halt];
		} else if ([type isEqualToString:@"postpone no more"]) {
			[timerInfo halt];
		} else if ([type isEqualToString:@"halt"]) {
			[timerInfo run];
		}
	}
	[[NSUserNotificationCenter defaultUserNotificationCenter] removeDeliveredNotification:notification];
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
				   ^{
					   BOOL notificationStillPresent;
					   do {
						   notificationStillPresent = NO;
						   for (NSUserNotification *nox in [[NSUserNotificationCenter defaultUserNotificationCenter] deliveredNotifications]) {
							   if ([nox.identifier isEqualToString:notification.identifier]) notificationStillPresent = YES;
						   }
						   if (notificationStillPresent) [NSThread sleepForTimeInterval:0.20f];
					   } while (notificationStillPresent);
					   dispatch_async(dispatch_get_main_queue(), ^{
//						   NSLog(@"deliver %@ %ld", notification.identifier, notification.activationType);
						   [self handleNotification:notification];
					   });
				   });
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
//	NSLog(@"activate %@ %ld", notification.identifier, notification.activationType);
	[self handleNotification:notification];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
	return YES;
}

#pragma mark - Menu Actions
- (IBAction)turnOffClicked:(id)sender {
	NSAlert *alert = [[NSAlert alloc] init];
	alert.messageText = NSLocalizedString(@"Time's still ticking!", @"turn off alert title");
	alert.informativeText = NSLocalizedString(@"The timer of Halt is now running, and has to be reset when you turn on Halt for the next time. Are you sure you want to turn off?", @"turn off alert content");
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert addButtonWithTitle:NSLocalizedString(@"No", @"no button")];
	[alert addButtonWithTitle:NSLocalizedString(@"Yes", @"yes button")];
	NSModalResponse response = [alert runModal];
	if (response == NSAlertSecondButtonReturn) {
		[timerInfo off];
	}
}

- (IBAction)turnOnClicked:(id)sender {
	[timerInfo run];
}

- (IBAction)openPreferences:(id)sender {
	preferenceController = [[PreferenceController alloc] init];
	[preferenceController showWindow:self];
}

@end
