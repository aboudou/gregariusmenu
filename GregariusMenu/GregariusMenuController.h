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
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
