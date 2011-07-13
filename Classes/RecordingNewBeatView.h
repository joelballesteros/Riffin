//
//  RecordNewBeatView.h
//  Solocaster
//
//  Created by Nikki Fernandez on 11/4/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface RecordingNewBeatView : UIView <UIScrollViewDelegate, AVAudioPlayerDelegate>
{
	int instrument;
	int tempo;
	int loopLength;
	int elapsedMin;
	int elapsedSec;
	BOOL isRecordBeat;
    
	float tempoTimeInterval;
	int drumPad;
	int tempoTapCount;
	NSMutableArray *tempoTapTimeArray;
	
	BOOL isPlayMode;
	BOOL isRecordMode;
	BOOL hasReachedEnd;
    
    // Data Array
	NSMutableArray *drumKitArray;
    
    NSMutableArray *selectedDrumPadArray;
    int beatCounter;
    int metronomeCounter;
	
	// Button modes for rewind and forward buttons
	int buttonMode;
	int buttonScanningRew;
	int buttonScanningFwd;
	int buttonStalling;
	int buttonIdle;
	
	// Controls
	UIButton *cancelButton;
	UILabel *cancelLabel;
	UIButton *doneButton;
	UILabel *doneLabel;
	UILabel *beatLabel;
	UIScrollView *instrumentScrollView;
	UIButton *loopLength4Button;
	UIButton *loopLength8Button;
	UIButton *loopLength12Button;
	UIButton *loopLength16Button;
	UIButton *tempoButton;
	UILabel *tempoLabel;
	UISlider *timeSlider;
	
	// Player
	UIButton *rewindButton;
	UILabel *rewindLabel;
	UIButton *playButton;
	UILabel *playLabel;
	UIButton *fastForwardButton;
	UILabel *fastForwardLabel;
	UIButton *recordButton;
	UILabel *recordLabel;
	
	NSTimer *playTimer;
	NSTimer *metronomeTimer;
	NSTimer *scanTimer;

	NSNotificationCenter *nc;
}

@property (nonatomic, assign) int tempo;
@property (nonatomic, assign) int loopLength;
@property (nonatomic, assign) int elapsedMin;
@property (nonatomic, assign) int elapsedSec;
@property (nonatomic, assign) BOOL isRecordBeat;

@property (nonatomic, retain) NSMutableArray *drumKitArray;
@property (nonatomic, retain) NSMutableArray *selectedDrumPadArray;

-(void) fillInViewValues;
-(void) tappedCancelButton:(id) sender;
-(void) tappedDoneButton:(id) sender;
-(void) tappedTempoButton:(id) sender;
-(void) tappedLoopLengthButton:(id) sender;
-(void) tappedDrumPad:(id) sender;

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

// Play Button Methods
-(void) tappedPlayButton:(id) sender;
-(void) startPlayer;
-(void) pausePlayer;
-(void) didPlayMoveTimeSlider;
-(void) updatePlayControlState:(BOOL) isPlaying;

// Record Button Methods
-(void) tappedRecordButton:(id) sender;
-(void) startRecorder;
-(void) stopRecorder;
-(void) updateRecordControlState:(BOOL) isRecording;

// Beat Metronome
-(void) didPlayMetronome;

// Time Slider Methods
-(void) didMoveTimeSlider;
-(void) sendTimeSliderNotification;

@end
