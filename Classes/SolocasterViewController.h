//
//  SolocasterViewController.h
//  Solocaster
//
//  Created by Nikki Fernandez on 11/2/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SolocasterAppDelegate.h"
#import "RecordingViewController.h"
#import "RecordingNewBeatViewController.h"
#import "TrackViewController.h"
#import "SongViewController.h"
#import "SettingsViewController.h"
#import "SolocasterDataSource.h"

@interface SolocasterViewController : UIViewController <UITabBarControllerDelegate>
{
	SolocasterAppDelegate *mainDelegate;
	RecordingViewController *recordingViewController;
	RecordingNewBeatViewController *recordingNewBeatViewController;
	TrackViewController *trackViewController;
	SongViewController *songViewController;
	SettingsViewController *settingsViewController;
	
	UIImageView *launchImage;
	UITabBarController *tabController;
	NSMutableArray *localControllersArray;
	
	// For Tab bars
	UIImageView *recordView;
	UILabel *recordLabel;
	UIImageView *mixView;
	UILabel *mixLabel;
	UIImageView *songsView;
	UILabel *songsLabel;
	UIImageView *settingsView;
	UILabel *settingsLabel;
	int tabSelectedIndex;
	
	NSNotificationCenter *nc;
}


@property (nonatomic, retain) RecordingViewController *recordingViewController;
@property (nonatomic, retain) RecordingNewBeatViewController *recordingNewBeatViewController;
@property (nonatomic, retain) TrackViewController *trackViewController;
@property (nonatomic, retain) SongViewController *songViewController;
@property (nonatomic, retain) SettingsViewController *settingsViewController;
@property (nonatomic, retain) UITabBarController *tabController;

-(void) showTabBarController;
-(void) hideTabBarController;
-(void) hideLaunchPage;
-(void) updateTabBarState:(int) tabIndex;
-(void) selectMixTabBar;

@end

