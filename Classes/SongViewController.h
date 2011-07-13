//
//  SongViewController.h
//  Solocaster
//
//  Created by Nikki Fernandez on 12/9/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SongView.h"
#import "SolocasterAppDelegate.h"

@interface SongViewController : UIViewController 
{
	SongView *songView;
	SolocasterAppDelegate *mainDelegate;
	NSNotificationCenter *nc;
}

-(void) initializeNotification;
-(void) reloadSongList;
-(void) didRearrangeSongs:(NSNotification *) note;
-(void) didLoadSongs:(NSNotification *) note;
-(void) didDisableSongsTabBar;
-(void) didEnableSongsTabBar;

@end
