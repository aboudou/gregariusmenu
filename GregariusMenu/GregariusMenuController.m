//
//  GregariusMenuController.m
//  GregariusMenu
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


#import "GregariusMenuController.h"
#import "PreferencesController.h"

#import <Growl/GrowlApplicationBridge.h>
#import <Growl/GrowlDefines.h>

#define GROWL_NOTIFICATION_DEFAULT @"NotificationDefault"

static NSString *appName = @"GregariusMenu";

@implementation GregariusMenuController


-(void)awakeFromNib
{
	
	statusItem=[[[NSStatusBar systemStatusBar]statusItemWithLength:NSVariableStatusItemLength] retain];
	
	pollrate=[[[NSUserDefaults standardUserDefaults] stringForKey:CDCPollRate] intValue];
	
	mainTimer=[[NSTimer scheduledTimerWithTimeInterval:(pollrate)
												target:self
											  selector:@selector(timer:)
											  userInfo:nil
											   repeats:YES] retain];
	
	[statusItem setHighlightMode:YES];
	[statusItem setTitle:@"*"];
	[statusItem setToolTip:NSLocalizedString(@"StartingGregariusMenu",@"StartingGregariusMenu")];
	[statusItem setMenu:theMenu];
	[statusItem setEnabled:YES];
	
	[mainTimer fire];
}

+(void)initialize
{
	NSMutableDictionary *defaultValues=[NSMutableDictionary dictionary];
	[defaultValues setObject:@"http://localhost/" forKey: CDCGregariusURLKey];
	[defaultValues setObject:@"30" forKey:CDCPollRate];
	[defaultValues setObject:@"1" forKey:CDCNotifyGrowl];
	[defaultValues setObject:@"0" forKey:CDCNotifyBeep];
	[defaultValues setObject:@"10" forKey:CDCSnoozeTime];
	[defaultValues setObject:@"0" forKey:CDCAutoSnooze];
	[defaultValues setObject:@"0" forKey:CDCNixonMode];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
	
}

-(void)growlDidLaunch:(void *)context {
	
	
	NSArray *defaultAndAllNotification=[NSArray arrayWithObject:GREGARIUSMENU_MOREUNREAD ];
	
	NSImage *icon=[NSImage imageNamed:appName];
	iconData=[[icon TIFFRepresentation] retain];
	
	
	NSDictionary *regDict = [NSDictionary dictionaryWithObjectsAndKeys:
		@"GregariusMenu", GROWL_APP_NAME, 
		iconData,GROWL_APP_ICON,
		defaultAndAllNotification, GROWL_NOTIFICATIONS_ALL, 
		defaultAndAllNotification, GROWL_NOTIFICATIONS_DEFAULT,
		nil];
	
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:GROWL_APP_REGISTRATION 
																   object:nil 
																 userInfo:regDict];	
}

-(id)init
{
	if((self=[super init]))
	{
		// For listening to changes in preferences....
		NSNotificationCenter *nc;
		nc=[NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(handlePrefsChange:) name:@"CDCPrefsChanged" object:nil];
		
		oldunread=-1;
		snoozing=false;
		
		if([GrowlApplicationBridge isGrowlInstalled])
		{
				[GrowlApplicationBridge setGrowlDelegate:self];
		}
	}
	
	return self;
}

-(void)dealloc
{   
	NSNotificationCenter *nc;
    nc=[NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
	
	[iconData release];
	[statusItem release];
	[mainTimer invalidate];
	[mainTimer release];
	
	[preferencesController release];
	
	[super dealloc];
}

-(void)notifyUnread:(int)unread
{
	NSString *growl=[[NSUserDefaults standardUserDefaults] stringForKey:CDCNotifyGrowl];
	NSString *beep=[[NSUserDefaults standardUserDefaults] stringForKey:CDCNotifyBeep];
	
	if([growl intValue]==1)
	{
		NSDictionary *noteDict;
		NSImage *icon=[NSImage imageNamed:appName];
		iconData=[[icon TIFFRepresentation] retain];
		
		NSString *descstring=unread==1?
			[NSString stringWithFormat:NSLocalizedString(@"GrowlGregariusNewUnreadMessage",@"GrowlGregariusNewUnreadMessage"),unread]:
			[NSString stringWithFormat:NSLocalizedString(@"GrowlGregariusNewUnreadMessages",@"GrowlGregariusNewUnreadMessage"),unread];
		
		noteDict = [NSDictionary dictionaryWithObjectsAndKeys:
			GREGARIUSMENU_MOREUNREAD, GROWL_NOTIFICATION_NAME,
			appName, GROWL_APP_NAME,
			NSLocalizedString(@"GrowlGregariusNewUnread",@"GrowlGregariusNewUnread"), GROWL_NOTIFICATION_TITLE,
			descstring, GROWL_NOTIFICATION_DESCRIPTION,
			[icon TIFFRepresentation], GROWL_NOTIFICATION_ICON,
			nil];
		
		[GrowlApplicationBridge notifyWithDictionary:noteDict];
	}
	
	if([beep intValue]==1)
	{
		NSBeep();
	}
}

- (NSDictionary *) registrationDictionaryForGrowl {  
 
	NSArray *notifications=[NSArray arrayWithObject:GREGARIUSMENU_MOREUNREAD ];

 	 return [NSDictionary dictionaryWithObjectsAndKeys:notifications, GROWL_NOTIFICATIONS_ALL, notifications, GROWL_NOTIFICATIONS_DEFAULT, nil];  
	}
	
-(void)timer:(NSTimer *)timer
{
	NSString *gregariusurlstring;
	NSURL *gregariusurl;
	NSString *result;
	NSString *gregariuscheckedurl;
	NSArray *resultarray;
	NSString *resultvalue;
	
	gregariuscheckedurl=[[NSUserDefaults standardUserDefaults] stringForKey:CDCGregariusURLKey];
		
	if([gregariuscheckedurl length]==0) 
	{
		[statusItem setTitle:@"!"];
		[statusItem setToolTip:NSLocalizedString(@"CheckGregariusURL",@"CheckGregariusURL")];
		[self openPreferences:self];
		return;
	}
	
	if([[[NSUserDefaults standardUserDefaults] stringForKey:CDCNewGregariusRPC] intValue]!=0)
	{
		gregariusurlstring=[NSString stringWithFormat:@"%@/api.php?method=update",gregariuscheckedurl];
	}
	else
	{
		gregariusurlstring=[NSString stringWithFormat:@"%@/rpc.php",gregariuscheckedurl];
	}
	
	gregariusurl=[NSURL URLWithString:gregariusurlstring];
	
	NSError *error;
	NSURLResponse *response;
	NSURLRequest *request = [NSURLRequest requestWithURL:gregariusurl
											 cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
	
	NSData *data = [NSURLConnection sendSynchronousRequest:request
										 returningResponse:&response error:&error];
	
	if([data length]!=0)
	{
		result=[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
		resultarray=[result componentsSeparatedByString:@"|"];
		
		[result release];
		
		if([resultarray count] > 1)
		{
			resultvalue=[resultarray objectAtIndex:1];
		} else {
			resultvalue= @"-1";			
		}
		
		if([resultvalue isEqualToString:@"-1"])
		{
			[statusItem setTitle:@"!"];
			[statusItem setToolTip:NSLocalizedString(@"CheckGregariusURL",@"CheckGregariusURL")];
		}
		else
		{
			int unread;
			
			unread=[resultvalue intValue];
			
			if(oldunread==-1)
			{
				if(unread>0)
				{
					[self notifyUnread:unread];
				}
				
				oldunread=unread;
			}
			else
			{
				if(unread>oldunread)
				{
					[self notifyUnread:unread];
				}
				
				oldunread=unread;
			}
			
			NSString *descstring=unread==1?
				[NSString stringWithFormat:NSLocalizedString(@"TooltipUnreadMessage",@"TooltipUnreadMessage"),unread]:
				[NSString stringWithFormat:NSLocalizedString(@"TooltipUnreadMessages",@"TooltipUnreadMessage"),unread];
			
			[statusItem setTitle:[resultarray objectAtIndex:1]];
			[statusItem setToolTip:descstring];
			
		}
	}
	else
	{
		[statusItem setTitle:@"T"];
		[statusItem setToolTip:NSLocalizedString(@"ErrorWhileChecking",@"ErrorWhileChecking")];
	}
	
}

-(IBAction)snoozeNow:(id)sender
{
	[mainTimer invalidate];
	[mainTimer release];

	if([[[NSUserDefaults standardUserDefaults] stringForKey:CDCNixonMode] intValue]!=0)
	{
		[statusItem setTitle:@"0"];
	}
	else
	{
		[statusItem setTitle:@"Z"];
	}
	
	[statusItem setToolTip:@"Snoozing"];
	
	snoozetime=[[[NSUserDefaults standardUserDefaults] stringForKey:CDCSnoozeTime] intValue];
	
	snoozing=true;
	oldunread=-1;
	
	mainTimer=[[NSTimer scheduledTimerWithTimeInterval:(snoozetime*60)
												target:self
											  selector:@selector(snoozeOver:)
											  userInfo:nil
											   repeats:NO] retain];
	
}

-(void)snoozeOver:(NSTimer *)timer
{
	[mainTimer invalidate];
	[mainTimer release];
	
	snoozing=false;
	
	mainTimer=[[NSTimer scheduledTimerWithTimeInterval:(pollrate)
												target:self
											  selector:@selector(timer:)
											  userInfo:nil
											   repeats:YES] retain];
	
	[mainTimer fire];
}

-(IBAction)checkNow:(id)sender
{
	if(snoozing)
	{
		[self snoozeOver:nil];
	}
	else
	{
		[mainTimer fire];
	}
}

-(void)handlePrefsChange:(NSNotification *)aNotification
{
	[mainTimer invalidate];
	[mainTimer release];
	
	pollrate=[[[NSUserDefaults standardUserDefaults] stringForKey:CDCPollRate] intValue];
	snoozetime=[[[NSUserDefaults standardUserDefaults] stringForKey:CDCSnoozeTime] intValue];

	if(!snoozing)
	{
				
		mainTimer=[[NSTimer scheduledTimerWithTimeInterval:(pollrate)
													target:self
												  selector:@selector(timer:)
												  userInfo:nil
												   repeats:YES] retain];
		
		[mainTimer fire];
	}
	else
	{
		
		mainTimer=[[NSTimer scheduledTimerWithTimeInterval:(snoozetime*60)
													target:self
												  selector:@selector(snoozeOver:)
												  userInfo:nil
												   repeats:NO] retain];
	}
	
}

-(IBAction)openGregarius:(id)sender
{
	NSString *gregariuscheckedurl;
	
	gregariuscheckedurl=[[NSUserDefaults standardUserDefaults] stringForKey:CDCGregariusURLKey];
	
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:gregariuscheckedurl]];

	if(!snoozing && [[[NSUserDefaults standardUserDefaults] stringForKey:CDCAutoSnooze] intValue]!=0)
	{
		[self snoozeNow:nil];
	}
	
}

-(IBAction)openPreferences:(id)sender
{
	if(!preferencesController)
		preferencesController=[[PreferencesController alloc] init];
	
	[NSApp activateIgnoringOtherApps:YES];
	[[preferencesController window] makeKeyAndOrderFront:nil];
}

-(IBAction)openAbout:(id)sender
{
	[NSApp orderFrontStandardAboutPanel:nil];
}


@end
