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
