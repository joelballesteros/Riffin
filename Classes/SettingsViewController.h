//
//  SettingsViewController.h
//  Solocaster
//
//  Created by Nikki Fernandez on 11/3/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SettingsView.h"
#import "AboutView.h"
#import "SolocasterAppDelegate.h"

@interface SettingsViewController : UIViewController 
{
	SolocasterAppDelegate *mainDelegate;
	SettingsView *settingsView;
	AboutView *aboutView;
	
	NSNotificationCenter *nc;
}

-(void) initializeNotification;

-(void) didShowAbout;
-(void) didGoBackToSettings;

-(void) didSwitchRecordBeatSettings:(NSNotification *) note;
-(void) didSwitchRecordInstrumentSettings:(NSNotification *) note;

-(void) didDisableSettingsTabBar;
-(void) didEnableSettingsTabBar;

@end
