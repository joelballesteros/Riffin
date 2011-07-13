//
//  TracksVolumeView.h
//  Solocaster
//
//  Created by Nikki Fernandez on 11/4/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioServices.h>

@interface TracksVolumeView : UIView <UIActionSheetDelegate, AVAudioPlayerDelegate>
{
	int songID;
	int elapsedMin;
	int elapsedSec;
	int tempo;
	int loopLength;
    
    int beatCounter;
	BOOL isPlayMode;
    BOOL hasReachedEnd;
	float tempoTimeInterval;
	
    // Data
	NSMutableArray *trackObjectArray;
	NSMutableArray *instrumentArray;
	NSMutableArray *drumKitArray;

	// Button modes for rewind and forward buttons
	int buttonMode;
	int buttonScanningRew;
	int buttonScanningFwd;
	int buttonStalling;
	int buttonIdle;
	
	// Controls
	UIButton *shareButton;
	UILabel *shareLabel;
	UIButton *saveButton;
	UILabel *saveLabel;
	UIButton *volumeButton;
	UILabel *volumeLabel;
	UIButton *pitchButton;
	UILabel *pitchLabel;
	UISlider *track1VolumeSlider;
	UISlider *track2VolumeSlider;
	UISlider *track3VolumeSlider;
	UISlider *track4VolumeSlider;
	UIButton *track1NameButton;
	UIButton *track2NameButton;
	UIButton *track3NameButton;
	UIButton *track4NameButton;
	UIButton *track1NumberButton;
	UIButton *track2NumberButton;
	UIButton *track3NumberButton;
	UIButton *track4NumberButton;
	UILabel *elapsedTimeLabel;	
	UISlider *timeSlider;
	UISlider *bpmSlider;
	UILabel *bpmLabel;
	
	// Music player
	UIButton *rewindButton;
	UILabel *rewindLabel;
	UIButton *playButton;
	UILabel *playLabel;
	UIButton *fastForwardButton;
	UILabel *fastForwardLabel;
	UIButton *recordButton;
	UILabel *recordLabel;
	NSTimer *playTimer;
    NSTimer *playDrumsTimer;
	NSTimer *rewTimer;
	NSTimer *fwdTimer;
		
	// Detect double tap count on rewind button
	NSDate *prevRewindTapTime;
	
	// Alert
	UIAlertView *notRecordedAlert;
	
	NSNotificationCenter *nc;
}

@property (nonatomic, assign) int songID;
@property (nonatomic, assign) int elapsedMin;
@property (nonatomic, assign) int elapsedSec;
@property (nonatomic, assign) int tempo;
@property (nonatomic, assign) int loopLength;
@property (nonatomic, retain) NSMutableArray *trackObjectArray;
@property (nonatomic, retain) NSMutableArray *instrumentArray;
@property (nonatomic, retain) NSMutableArray *drumKitArray;

// Control Methods
-(void) fillInViewValues;
-(void) tappedShareSongButton:(id) sender;
-(void) tappedSaveSongButton:(id) sender;
-(void) tappedPitchButton:(id) sender;

// Volume Slider Methods
-(void) didMoveTrack1VolumeSlider;
-(void) didMoveTrack2VolumeSlider;
-(void) didMoveTrack3VolumeSlider;
-(void) didMoveTrack4VolumeSlider;

// Tempo Slider Method
-(void) didMoveTempoSlider;
-(void) addTempoLabel;

// Rewind Button Methods
-(void) touchedDownRewindButton:(id) sender;
-(void) touchedUpInsideRewindButton:(id) sender;
-(void) tryRewindScan;
-(void) startRewindScan;
-(void) stopRewindScan;

// Forward Button Methods
-(void) touchedDownForwardButton:(id) sender;
-(void) touchedUpInsideForwardButton:(id) sender;
-(void) tryForwardScan;
-(void) startForwardScan;
-(void) stopForwardScan;

// Play Methods
-(void) tappedPlayButton:(id) sender;
-(void) startPlayer;
-(void) pausePlayer;
-(void) stopPlayer;
-(void) didPlayMoveTimeSlider;
-(void) didPlayDrums;
-(void) didMoveTimeSlider;
-(void) updatePlayControlState:(BOOL) isPlaying;

@end