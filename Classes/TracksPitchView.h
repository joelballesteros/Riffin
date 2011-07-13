//
//  TracksPitchView.h
//  Solocaster
//
//  Created by Nikki Fernandez on 11/4/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class BassObjectTrack;
@class MicObjectTrack;

@interface TracksPitchView : UIView <UIActionSheetDelegate, AVAudioPlayerDelegate>
{
	int songID;
	int elapsedMin;
	int elapsedSec;
	int tempo;
	int loopLength;
    
    int beatCounter;
	BOOL isPlayMode;
	BOOL isStopped;
	BOOL isPaused;
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
    
	UISlider *track1PitchSlider;
	UISlider *track2PitchSlider;
	UISlider *track3PitchSlider;
	UISlider *track4PitchSlider;
    
    UIView *volumeView;
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
	UIButton *track1Reverb;
	UIButton *track2Reverb;
	UIButton *track3Reverb;
	UIButton *track4Reverb;

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
    UIAlertView *reverbAlert;

	NSNotificationCenter *nc;
    
    BassObjectTrack *track1Pitch;
    BassObjectTrack *track2Pitch;
    BassObjectTrack *track3Pitch;
    BassObjectTrack *track4Pitch;
    BassObjectTrack *micRecPlayer;
}

@property (nonatomic, assign) int songID;
@property (nonatomic, assign) int elapsedMin;
@property (nonatomic, assign) int elapsedSec;
@property (nonatomic, assign) int tempo;
@property (nonatomic, assign) int loopLength;
@property (nonatomic, retain) NSMutableArray *trackObjectArray;
@property (nonatomic, retain) NSMutableArray *instrumentArray;
@property (nonatomic, retain) NSMutableArray *drumKitArray;
@property (nonatomic, retain) BassObjectTrack *track1Pitch;
@property (nonatomic, retain) BassObjectTrack *track2Pitch;
@property (nonatomic, retain) BassObjectTrack *track3Pitch;
@property (nonatomic, retain) BassObjectTrack *track4Pitch;
@property (nonatomic, retain) BassObjectTrack *micRecPlayer;

// Control Methods
-(void) fillInViewValues;
-(void) tappedVolumeButton:(id) sender;
-(void) tappedPitchButton:(id) sender;
-(void) tappedShareSongButton:(id) sender;
-(void) tappedSaveSongButton:(id) sender;

// Pitch Slider Methods
-(void) didMoveTrack1PitchSlider;
-(void) didMoveTrack2PitchSlider;
-(void) didMoveTrack3PitchSlider;
-(void) didMoveTrack4PitchSlider;
-(void) updateTrackPlayerPitch:(float)pitch onTrackNumber:(int)track;

// Volume Slider Methods
-(void) didMoveTrack1VolumeSlider;
-(void) didMoveTrack2VolumeSlider;
-(void) didMoveTrack3VolumeSlider;
-(void) didMoveTrack4VolumeSlider;
-(void) showVolume;

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
-(void) didMoveTimeSlider;
-(void) updatePlayControlState:(BOOL) isPlaying;

// Snap Pitch Slider
-(float) snapPitchSlider:(float) currSliderValue;

// Reverb Method
-(void) tappedReverb1;
-(void) applyReverb1:(UISegmentedControl *) sender;
-(void) tappedReverb2;
-(void) applyReverb2:(UISegmentedControl *) sender;
-(void) tappedReverb3;
-(void) applyReverb4:(UISegmentedControl *) sender;
-(void) tappedReverb4;
-(void) applyReverb4:(UISegmentedControl *) sender;
-(void) performDismiss;

@end
