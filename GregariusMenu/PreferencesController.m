//
//  PreferencesController.m
//  GregariusMenu
//
//
// Copyright 2005 Codepope/Runstate
//
// Adapted by Arnaud Boudou for GregariusMenu
// Copyright 2005-2009 Arnaud Boudou. All rights reserved.
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


#import "PreferencesController.h"

NSString *CDCGregariusURLKey=@"Gregarius URL (with http://):"; 
NSString *CDCPollRate=@"Poll Rate";
NSString *CDCNotifyBeep=@"Notify Beep";
NSString *CDCNotifyGrowl=@"Notify Growl";
NSString *CDCAutoSnooze=@"Auto Snooze";
NSString *CDCNixonMode=@"Nixon Mode";
NSString *CDCSnoozeTime=@"Snooze Time";
NSString *CDCNewGregariusRPC=@"Gregarius 0.5.3+";
NSString *CDCStartAtLogin=@"Start At Login";

@implementation PreferencesController
-(id)init
{
	if((self=[super initWithWindowNibName:@"Preferences"]))
		[self setWindowFrameAutosaveName:@"PrefWindow"];
	
	return self;
}

-(void)windowDidLoad
{
	[gregariusURLField setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:CDCGregariusURLKey]];
	[pollRateField setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:CDCPollRate]];
	[growlNotificationButton setIntValue:[[[NSUserDefaults standardUserDefaults] stringForKey:CDCNotifyGrowl] intValue]];
	[beepNotificationButton setIntValue:[[[NSUserDefaults standardUserDefaults] stringForKey:CDCNotifyBeep] intValue]];
	[snoozeTimeField setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:CDCSnoozeTime]];
	[nixonModeButton setIntValue:[[[NSUserDefaults standardUserDefaults] stringForKey:CDCNixonMode] intValue]];
	[autosnoozeButton setIntValue:[[[NSUserDefaults standardUserDefaults] stringForKey:CDCAutoSnooze] intValue]];
	[newGregariusRPCButton setIntValue:[[[NSUserDefaults standardUserDefaults] stringForKey:CDCNewGregariusRPC] intValue]];
	[startAtLoginButton setIntValue:[[[NSUserDefaults standardUserDefaults] stringForKey:CDCStartAtLogin] intValue]];
}

-(IBAction)saveChanges:(id)sender
{
	NSNotificationCenter *nc;

	nc=[NSNotificationCenter defaultCenter];


	[[NSUserDefaults standardUserDefaults] setObject:[gregariusURLField stringValue] forKey:CDCGregariusURLKey];
	[[NSUserDefaults standardUserDefaults] setObject:[pollRateField stringValue] forKey:CDCPollRate];
	[[NSUserDefaults standardUserDefaults] setObject:[growlNotificationButton stringValue] forKey:CDCNotifyGrowl];
	[[NSUserDefaults standardUserDefaults] setObject:[beepNotificationButton stringValue] forKey:CDCNotifyBeep];
	[[NSUserDefaults standardUserDefaults] setObject:[snoozeTimeField stringValue] forKey:CDCSnoozeTime];
	[[NSUserDefaults standardUserDefaults] setObject:[autosnoozeButton stringValue] forKey:CDCAutoSnooze];
	[[NSUserDefaults standardUserDefaults] setObject:[nixonModeButton stringValue] forKey:CDCNixonMode];
	[[NSUserDefaults standardUserDefaults] setObject:[newGregariusRPCButton stringValue] forKey:CDCNewGregariusRPC];
	[[NSUserDefaults standardUserDefaults] setObject:[startAtLoginButton stringValue] forKey:CDCStartAtLogin];
	[[self window] performClose:nil];
	
	[nc postNotificationName:@"CDCPrefsChanged" object:self];

}

-(void)windowWillClose:(NSNotification *)aNotification
{
	[gregariusURLField abortEditing];
	[pollRateField abortEditing];
	[snoozeTimeField abortEditing];
	
	[gregariusURLField setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:CDCGregariusURLKey]];
	[pollRateField setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:CDCPollRate]];
	[snoozeTimeField setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:CDCSnoozeTime]];
}

//Add or remove an application from one user's login items (YES to add, NO to remove)

- (void)setMyAppInLoginItems:(BOOL)doAdd {
        // First, get the login items from loginwindow pref
        NSMutableArray* loginItems = (NSMutableArray*) CFPreferencesCopyValue((CFStringRef) @"AutoLaunchedApplicationDictionary",
                 (CFStringRef) @"loginwindow", kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
        BOOL changed = NO, foundMyAppItem = NO;
        int myAppItemIndex = 0;
		NSString *kDTMyAppAppPath = [[NSBundle mainBundle] bundlePath]; 
		
        if (loginItems) {
                NSEnumerator *enumer;
                NSDictionary *itemDict;

                // Detirmine if myApp is in list
                enumer=[loginItems objectEnumerator];
                while ((itemDict=[enumer nextObject])) {
                        if ([[itemDict objectForKey:@"Path"] isEqualToString:kDTMyAppAppPath]) {
                                foundMyAppItem = YES;
                                break;
                        }
                        myAppItemIndex++;
                }
        }
        // If we're adding, we want to add if not found. If we're removing, we want to remove if found
        if (doAdd && !foundMyAppItem) {
                // OK, Create item and add it - should work even if no pref existed
                NSDictionary    *myAppItem;
                FSRef                   myFSRef;
                OSStatus                fsResult = FSPathMakeRef((const UInt8 *)[kDTMyAppAppPath fileSystemRepresentation], &myFSRef, NULL);

                if (loginItems) {
                        loginItems = [[loginItems autorelease] mutableCopy]; // mutable copy we can work on, autorelease the original
                } else {
                        loginItems = [[NSMutableArray alloc] init];     // didn't find this pref, make from scratch
                }
                // ref from path as NSString 
                if (fsResult == noErr) {
                        AliasHandle myAliasHndl = NULL;

                        //make alias record, a handle of variable length                        
                        fsResult = FSNewAlias(NULL, &myFSRef, &myAliasHndl);
                        if (fsResult == noErr && myAliasHndl != NULL) {
                                // Add the item
                                myAppItem = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSData dataWithBytes:*myAliasHndl length:GetHandleSize((Handle)myAliasHndl)],
                                        @"AliasData", [NSNumber numberWithBool:NO], @"Hide", kDTMyAppAppPath, @"Path", nil];
                                [loginItems addObject:myAppItem];
                                // release the new alias handle
                                DisposeHandle((Handle)myAliasHndl);
                                changed = YES;
                        }
                }
        } else if (!doAdd && foundMyAppItem) {
                loginItems = [[loginItems autorelease] mutableCopy]; // mutable copy we can work on, autorelease the original
                [loginItems removeObjectAtIndex:myAppItemIndex]; // remove the MyApp item in the loginItems array
				changed=YES;
        }

        if (changed) {
                // Set new value in pref
                CFPreferencesSetValue((CFStringRef) 
                                                          @"AutoLaunchedApplicationDictionary", loginItems, (CFStringRef) 
                                                          @"loginwindow", kCFPreferencesCurrentUser, kCFPreferencesAnyHost); 
                CFPreferencesSynchronize((CFStringRef) @"loginwindow", kCFPreferencesCurrentUser, kCFPreferencesAnyHost); 
        }
        [loginItems release]; 
}

-(IBAction)setStartOnLogin:(id)sender
{
	NSLog(@"%@\n",[startAtLoginButton stringValue]);
	if([startAtLoginButton intValue]==1)
	{
		[self setMyAppInLoginItems:(BOOL)1];
	}
	else
	{
		[self setMyAppInLoginItems:(BOOL)0];
	}
	
}

@end
