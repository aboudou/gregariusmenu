//
//  PreferencesController.h
//  GregariusMenu
//
//  Created by Dj Walker-Morgan on 26/12/2004.
//  Copyright 2004 Runstate/Codepope. All rights reserved.
//
//  Adapted by Arnaud Boudou for GregariusMenu
//  Copyright 2005-2009 Arnaud Boudou. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *CDCGregariusURLKey;
extern NSString *CDCPollRate;
extern NSString *CDCNotifyBeep;
extern NSString *CDCNotifyGrowl;
extern NSString *CDCSnoozeTime;
extern NSString *CDCAutoSnooze;
extern NSString *CDCNixonMode;
extern NSString *CDCNewGregariusRPC;
extern NSString *CDCStartAtLogin;

@interface PreferencesController : NSWindowController {
	IBOutlet NSTextField *gregariusURLField;
	IBOutlet NSTextField *pollRateField;
	IBOutlet NSButton *beepNotificationButton;
	IBOutlet NSButton *growlNotificationButton;
	IBOutlet NSTextField *snoozeTimeField;
	IBOutlet NSButton *autosnoozeButton;
	IBOutlet NSButton *nixonModeButton;
	IBOutlet NSButton *newGregariusRPCButton;
	IBOutlet NSButton *startAtLoginButton;
}

-(IBAction)saveChanges:(id)sender;

@end
