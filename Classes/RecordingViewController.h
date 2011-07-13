//
//  RecordingViewController.h
//  Solocaster
//
//  Created by Nikki Fernandez on 11/2/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "RecordingScreenView.h"
#import "SaveNewSongView.h"
#import "ReplaceSong.h"
#import "SolocasterAppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>

@interface RecordingViewController : UIViewController <AVAudioPlayerDelegate>
{	
	SolocasterAppDelegate *mainDelegate;	
	RecordingScreenView *recordingScreenView;
	SaveNewSongView *saveNewSongView;
	ReplaceSong *replaceSong;
	
	NSNotificationCenter *nc;
}

-(void) initializeNotification;

-(void) didSelectRecordingScreen;
-(void) didSelectClearSong;
-(void) didShowSaveNewSongInRecording;
-(void) didReplaceSongInRecording;

-(void) didScrollTrackInstrument:(NSNotification *) note;
-(void) didChangeTrackNumber:(NSNotification *)note;
-(void) didMoveRecordingTimeSlider:(NSNotification *) note;
-(void) didUpdateTrack:(NSNotification *) note;

// Enable/Disable tab bar
-(void) didDisableRecordingTabBar;
-(void) didEnableRecordingTabBar;

@end
