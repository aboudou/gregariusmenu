//
//  GregariusMenuController.h
//  GregariusMenu
//
//  Created by Dj Walker-Morgan on 26/12/2004.
//  Copyright 2004 Runstate/Codepope. All rights reserved.
//
//  Adapted by Arnaud Boudou for GregariusMenu
//  Copyright 2005-2009 Arnaud Boudou. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <Growl/GrowlApplicationBridge.h>
#import <Growl/GrowlDefines.h>

#define GREGARIUSMENU_MOREUNREAD @"More Unread"

@class PreferencesController;

@interface GregariusMenuController : NSObject <GrowlApplicationBridgeDelegate> {
	
	NSStatusItem *statusItem;
	
	IBOutlet NSMenu *theMenu;
	
	NSTimer *mainTimer;
	
	PreferencesController *preferencesController;
	
	int pollrate;
	int snoozetime;
	
	int oldunread;
	
	bool snoozing;
	
	NSDictionary *unreadNotification;
	
	NSData *iconData;
}

-(void)timer:(NSTimer *)timer;
-(IBAction)openGregarius:(id)sender;
-(IBAction)openPreferences:(id)sender;
-(IBAction)snoozeNow:(id)sender;
-(IBAction)openAbout:(id)sender;
-(IBAction)checkNow:(id)sender;
-(void)growlDidLaunch:(void *)context;
-(void)notifyUnread:(int)unread;

@end
