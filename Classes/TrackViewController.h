//
//  TrackViewController.h
//  Solocaster
//
//  Created by Nikki Fernandez on 11/3/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TracksVolumeView.h"
#import "TracksPitchView.h"
#import "SaveNewSongView.h"
#import "ShareSongEmailView.h"
#import "ReplaceSong.h"
#import "SolocasterAppDelegate.h"

@interface TrackViewController : UIViewController
{
	SolocasterAppDelegate *mainDelegate;
	TracksVolumeView *tracksVolumeView;
	TracksPitchView *tracksPitchView;
	SaveNewSongView *saveNewSongView;
	ShareSongEmailView *shareSongEmailView;
	ReplaceSong *replaceSong;
	
	BOOL isLastViewVolume;
	
	NSNotificationCenter *nc;
}

@property (nonatomic, assign) BOOL isLastViewVolume;

-(void) initializeNotification;
-(void) didSelectVolume;
-(void) didSelectPitch;

-(void) didChangeTempo:(NSNotification *)note;

-(void) didShowSaveNewSong;
-(void) didSaveNewSongWithName:(NSNotification *)note;
-(void) didSaveNewSong:(NSNotification *)note;
-(void) didCancelSaveNewSong;
-(void) didReplaceSong;
-(void) didShareSongEmail;

-(void) didMoveVolumeSlider:(NSNotification *) note;
-(void) didMovePitchSlider:(NSNotification *) note;
-(void) didMoveVolumeTimeSlider:(NSNotification *) note;
-(void) didMovePitchTimeSlider:(NSNotification *) note;

-(void) didDisableTracksTabBar;
-(void) didEnableTracksTabBar;


@end
