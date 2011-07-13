//
//  RecordingScreenView.h
//  Solocaster
//
//  Created by Nikki Fernandez on 11/3/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AQLevelMeter.h"
#import <AudioToolbox/AudioServices.h>

@class MicRecording;

@interface RecordingScreenView : UIView <UIScrollViewDelegate, UIActionSheetDelegate, AVAudioPlayerDelegate, UITextFieldDelegate, UIAlertViewDelegate, AVAudioSessionDelegate>
{
    // Song Properties
	NSString *songName;
	int songID;
    int tempo;
	int loopLength;
    float tempoTimeInterval;
	
	int trackNumber;
	int instrument;
	int elapsedMin;
	int elapsedSec;
    int songDurationMax;
	
    BOOL isPlayMode;
	BOOL isRecordMode;
	BOOL onSaveMode;
	
	// Metronome Setting
	BOOL isRecordInstrument;
	BOOL isMicRecording;
	
	// Button modes for rewind and forward buttons
	int buttonMode;
	int buttonScanningRew;
	int buttonScanningFwd;
	int buttonStalling;
	int buttonIdle;
	
	// Data
	NSMutableArray *instrumentArray;
	NSMutableArray *drumKitArray;
	NSMutableArray *trackObjectArray;
	
	float trackBarStart;
	float trackUnitMultiplier; 
	
	BOOL hasReachedEnd;
	float recordStart;		// Time slider value when recording started
	float recordEnd;		// Time slider value when recording ended
	NSDate *prevInstrumentTapTime;

	NSURL *recorderURL;
    
	// Alerts
	UIAlertView *notRecordedAlert;
    UIAlertView *noDrumBeatsAlert;
	
	NSNotificationCenter *nc;

    // Mic Recorder
	MicRecording *micRecording;
	UIAlertView *micRecordingAlert;
	NSMutableArray *recordedMic;
	BOOL isPlayFromMic;
	AQLevelMeter* lvlMeter_in;
	int micRecordingPlayed;
    
    // Drum beat
    int beatCounter;
    
    // Controls
	UIButton *clearButton;
	UILabel *clearLabel;
	UIButton *saveButton;
	UILabel *saveLabel;	
	UITextField *songNameTextField;
	UIButton *track1Button;
	UIButton *track2Button;
	UIButton *track3Button;
	UIButton *loopButton;
	UIView *track1BarView;
	UIView *track2BarView;
	UIView *track3BarView;
	UIView *loopBarView;
    
    // Music Player
	UIButton *playButton;
	UILabel *playLabel;
	UIButton *rewindButton;
	UILabel *rewindLabel;
	UIButton *fastForwardButton;
	UILabel *fastForwardLabel;
	UIButton *recordButton;
	UILabel *recordLabel;
	UIScrollView *instrumentScrollView;
	UILabel *elapsedTimeLabel;
	UISlider *timeSlider;
	UISlider *timeSliderIndicator;
    
    // Timers
    NSTimer *playTimer;
    NSTimer *playDrumsTimer;
	NSTimer *recTimer;
    NSTimer *recDrumsTimer;
    NSTimer *rewTimer;
	NSTimer *fwdTimer;
    NSTimer *metronomeTimer;
}

@property (nonatomic, retain) NSString *songName;
@property (nonatomic, assign) int songID;
@property (nonatomic, assign) int tempo;
@property (nonatomic, assign) int loopLength;
@property (nonatomic, assign) int trackNumber;
@property (nonatomic, assign) int instrument;
@property (nonatomic, assign) int elapsedMin;
@property (nonatomic, assign) int elapsedSec;
@property (nonatomic, assign) int songDurationMax;
@property (nonatomic, assign) BOOL isRecordInstrument;
@property (nonatomic, retain) NSMutableArray *instrumentArray;
@property (nonatomic, retain) NSMutableArray *drumKitArray;
@property (nonatomic, retain) NSMutableArray *trackObjectArray;

@property (nonatomic, assign) BOOL isPlayFromMic;
@property (nonatomic, assign) int micRecordingPlayed;
@property (nonatomic, retain) MicRecording *micRecording;
@property (nonatomic, retain) NSMutableArray *recordedMicArray;
@property (nonatomic, retain) AQLevelMeter *lvlMeter_in;

// Controls
-(void) fillInViewValues;
-(void) tappedSaveButton:(id) sender;
-(void) tappedClearButton:(id) sender;
-(void) tappedInstrument;
-(void) tappedTrackButton:(id) sender;

// Rewind Button Methods
-(void) touchedUpInsideRewindButton:(id) sender;
-(void) touchedDownRewindButton:(id) sender;
-(void) tryRewindScan;
-(void) startRewindScan;
-(void) stopRewindScan;

// Fast Forward Button Methods
-(void) touchedUpInsideForwardButton:(id) sender;
-(void) touchedDownForwardButton:(id) sender;
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
-(void) updatePlayControlState:(BOOL) isPlaying;

// Record Button Methods
-(void) tappedRecordButton:(id) sender;
-(void) startRecorder;
-(void) stopRecorder;
-(void) didRecordMoveTimeSlider;
-(void) didRecordWithMetronome;
-(void) didRecordDrums;
-(void) updateRecordFlags;
-(void) updateRecordControlState:(BOOL) isRecording;

// Time Slider Methods
-(void) didMoveTimeSlider;
-(void) didMoveTimeSliderIndicator;
-(void) sendTimeSliderNotification;

-(NSString *) dateString;

@end
