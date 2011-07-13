//
//  RecordingScreenView.m
//  Solocaster
//
//  Created by Nikki Fernandez on 11/3/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import "RecordingScreenView.h"
#import <QuartzCore/QuartzCore.h>

#import "TrackObject.h"
#import "InstrumentObject.h"
#import "CircleView.h"
#import "MicRecording.h"

#define SKIP_TIME 5.0				// Number of skip seconds for fast forward, fast rewind
#define TIMESLIDER_MIN 0.0
#define TIMESLIDER_MAX 270.0

#define RECORDING_MINUTES 4
#define RECORDING_SECONDS 30

#define NOTRECORDED_FLAG 0
#define RECORDED_FLAG 1

#define LAYOUT_GAP 1				// Gap between controls in layout: 2 pixels = 1pt

#define TRACKBUTTON_TAG 300
#define TRACKBAR_TAG 400
#define CIRCLE_TAG 500
#define CLEARSONGAS_TAG 600
#define SAVESONGAS_TAG 601

#define DRUM_TRACK 3

// Color Macro
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define FILEPATH [DOCUMENTS_FOLDER stringByAppendingPathComponent:[self dateString]]


@implementation RecordingScreenView

@synthesize songName;
@synthesize songID;
@synthesize tempo;
@synthesize loopLength;
@synthesize trackNumber;
@synthesize instrument;
@synthesize elapsedMin;
@synthesize elapsedSec;
@synthesize songDurationMax;
@synthesize isRecordInstrument;
@synthesize instrumentArray;
@synthesize drumKitArray;
@synthesize trackObjectArray;

@synthesize isPlayFromMic;
@synthesize micRecordingPlayed;
@synthesize micRecording;
@synthesize recordedMicArray;
@synthesize lvlMeter_in;

- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) 
	{
        self.backgroundColor = RGBA(0, 0, 0, 1);
		
		// Initialize values
		songName = @"New Song 1";
		isPlayMode = NO;
		isRecordMode = NO;
		buttonScanningRew = 0;
		buttonScanningFwd = 1;
		buttonStalling = 2;
		buttonIdle = 3;		
		buttonMode = buttonIdle;
		onSaveMode = NO;
		nc = [NSNotificationCenter defaultCenter];
		
		float ypos = 0.0f;
		float sliderPos = 315.0f - TIMESLIDER_MAX;

		// SETUP NAVIGATION BAR COMPONENTS
		clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
		clearButton.frame = CGRectMake(0.0f, ypos, 79.25, 50.0f);
		[clearButton setImage:[UIImage imageNamed:@"clear-btn.png"] forState:UIControlStateNormal];
		[clearButton setImage:[UIImage imageNamed:@"clear-btn-inactive.png"] forState:UIControlStateDisabled];
		[clearButton setImage:[UIImage imageNamed:@"clear-btn-pressed.png"] forState:UIControlStateHighlighted];
		[clearButton addTarget:self action:@selector(tappedClearButton:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:clearButton];
		
		clearLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, clearButton.bounds.size.height - 15.0f, clearButton.bounds.size.width, 10.0f)];
		clearLabel.backgroundColor = [UIColor clearColor];
		clearLabel.font = [UIFont fontWithName:@"GrixelAcme7WideXtnd" size:8.0f];
		clearLabel.textAlignment = UITextAlignmentCenter;
		clearLabel.text = @"CLEAR";
		clearLabel.textColor = RGBA(200, 200, 200, 1);
		[clearButton addSubview:clearLabel];
		
		saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
		saveButton.frame = CGRectMake(240.75f, ypos, 79.25f, 50.0f);
		[saveButton setImage:[UIImage imageNamed:@"save-btn.png"] forState:UIControlStateNormal];
		[saveButton setImage:[UIImage imageNamed:@"save-btn-inactive.png"] forState:UIControlStateDisabled];
		[saveButton setImage:[UIImage imageNamed:@"save-btn-pressed.png"] forState:UIControlStateHighlighted];
		[saveButton addTarget:self action:@selector(tappedSaveButton:) forControlEvents:UIControlEventTouchUpInside];		
		[self addSubview:saveButton];
		
		saveLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, saveButton.bounds.size.height - 15.0f, saveButton.bounds.size.width, 10.0f)];
		saveLabel.backgroundColor = [UIColor clearColor];
		saveLabel.font = [UIFont fontWithName:@"GrixelAcme7WideXtnd" size:8.0f];
		saveLabel.textAlignment = UITextAlignmentCenter;
		saveLabel.text = @"SAVE";
		saveLabel.textColor = RGBA(200, 200, 200, 1);
		[saveButton addSubview:saveLabel];
		
		//-------------------------------------
		songNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(80.25f, ypos, 159.5f, 50.0f)];
		songNameTextField.delegate = self;
		songNameTextField.textColor = RGBA(200, 200, 200, 1);
		songNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		songNameTextField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
		songNameTextField.textAlignment = UITextAlignmentCenter;
		songNameTextField.backgroundColor = RGBA(80, 80, 80, 1);
		songNameTextField.font = [UIFont fontWithName:@"GrixelAcme7Wide" size:15.0f];
		songNameTextField.returnKeyType = UIReturnKeyDone;
		songNameTextField.keyboardAppearance = UIKeyboardAppearanceAlert;
		songNameTextField.keyboardType = UIKeyboardTypeEmailAddress;
		[self addSubview:songNameTextField];
		
		ypos = clearButton.bounds.size.height + LAYOUT_GAP;
		
		//-------------------------------------------------------------------
		// SETUP VIEW BACKGROUND
		UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, ypos, 320.0f, 280.5f)];
		bgView.image = [UIImage imageNamed:@"controller-bg.png"];
		
		UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, ypos, 320.0f, 250.0f)];
		blackView.backgroundColor = [UIColor blackColor];
		
		//-------------------------------------------------------------------
		// SETUP INSTRUMENT SCROLL
		UIImageView *instrumentView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, ypos + LAYOUT_GAP, 320.0f, 60.0f)];
		instrumentView.image = [UIImage imageNamed:@"nav-bar-shadow.png"];
		
		instrumentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(30.0f, ypos + 5.0f, 260.0f, instrumentView.bounds.size.height - 10.0f)];
		instrumentScrollView.bounces = NO;
		instrumentScrollView.showsHorizontalScrollIndicator = NO;
		instrumentScrollView.pagingEnabled = YES;
		instrumentScrollView.delegate = self;
		instrumentScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
		
		// SETUP CHEVRON BUTTONS
		UIButton *leftChevronButton = [UIButton buttonWithType:UIButtonTypeCustom];
		leftChevronButton.frame = CGRectMake(0.0f, 0.0f, 30.0f, instrumentView.bounds.size.height);
		leftChevronButton.backgroundColor = [UIColor clearColor];
		[leftChevronButton setImage:[UIImage imageNamed:@"chevron-left.png"] forState:UIControlStateNormal];
		[instrumentView addSubview:leftChevronButton];
		
		UIButton *rightChevronButton = [UIButton buttonWithType:UIButtonTypeCustom];
		rightChevronButton.frame = CGRectMake(290.0f, 0.0f, 30.0f, instrumentView.bounds.size.height);
		rightChevronButton.backgroundColor = [UIColor clearColor];
		[rightChevronButton setImage:[UIImage imageNamed:@"chevron-right.png"] forState:UIControlStateNormal];
		[instrumentView addSubview:rightChevronButton];
		
		ypos += (instrumentView.bounds.size.height + LAYOUT_GAP) + 5.0f;
		
		//-------------------------------------------------------------------
		// SETUP TRACK 1
		track1Button = [UIButton buttonWithType:UIButtonTypeCustom];
		track1Button.frame = CGRectMake(0.0f, ypos, 45.0f, 45.0f);
		track1Button.tag = TRACKBUTTON_TAG;
		[track1Button setImage:[UIImage imageNamed:@"1-btn.png"] forState:UIControlStateNormal];
		[track1Button setImage:[UIImage imageNamed:@"1-btn-inactive.png"] forState:UIControlStateDisabled];
		[track1Button setImage:[UIImage imageNamed:@"1-btn-selected.png"] forState:UIControlStateSelected];
		[track1Button addTarget:self action:@selector(tappedTrackButton:) forControlEvents:UIControlEventTouchUpInside];

		track1BarView = [[UIView alloc] initWithFrame:
								   CGRectMake(track1Button.bounds.origin.x + track1Button.bounds.size.width + LAYOUT_GAP, 
											  ypos, 
											  273.0f, 
											  track1Button.bounds.size.height)];
		track1BarView.backgroundColor = RGBA(40, 40, 40, 1);
		track1BarView.tag = TRACKBAR_TAG;
		ypos += track1Button.bounds.size.height + LAYOUT_GAP;
		
		// SETUP TRACK 2
		track2Button = [UIButton buttonWithType:UIButtonTypeCustom];
		track2Button.frame = CGRectMake(0.0f, ypos, 45.0f, 45.0f);
		track2Button.tag = TRACKBUTTON_TAG + 1;
		[track2Button setImage:[UIImage imageNamed:@"2-btn.png"] forState:UIControlStateNormal];
		[track2Button setImage:[UIImage imageNamed:@"2-btn-inactive.png"] forState:UIControlStateDisabled];
		[track2Button setImage:[UIImage imageNamed:@"2-btn-selected.png"] forState:UIControlStateSelected];
		[track2Button addTarget:self action:@selector(tappedTrackButton:) forControlEvents:UIControlEventTouchUpInside];
		
		track2BarView = [[UIView alloc] initWithFrame:
								   CGRectMake(track2Button.bounds.origin.x + track2Button.bounds.size.width + LAYOUT_GAP, 
											  ypos, 
											  273.0f, 
											  track2Button.bounds.size.height)];
		track2BarView.backgroundColor = RGBA(40, 40, 40, 1);
		track2BarView.tag = TRACKBAR_TAG + 1;
		ypos += track2Button.bounds.size.height + LAYOUT_GAP;
		
		// SETUP TRACK 3
		track3Button = [UIButton buttonWithType:UIButtonTypeCustom];
		track3Button.frame = CGRectMake(0.0f, ypos, 45.0f, 45.0f);
		track3Button.tag = TRACKBUTTON_TAG + 2;
		[track3Button setImage:[UIImage imageNamed:@"3-btn.png"] forState:UIControlStateNormal];
		[track3Button setImage:[UIImage imageNamed:@"3-btn-inactive.png"] forState:UIControlStateDisabled];
		[track3Button setImage:[UIImage imageNamed:@"3-btn-selected.png"] forState:UIControlStateSelected];
		[track3Button addTarget:self action:@selector(tappedTrackButton:) forControlEvents:UIControlEventTouchUpInside];
		
		track3BarView = [[UIView alloc] initWithFrame:
								   CGRectMake(track3Button.bounds.origin.x + track3Button.bounds.size.width + LAYOUT_GAP, 
											  ypos, 
											  273.0f, 
											  track3Button.bounds.size.height)];
		track3BarView.backgroundColor = RGBA(40, 40, 40, 1);
		track3BarView.tag = TRACKBAR_TAG + 2;
		ypos += track3Button.bounds.size.height + LAYOUT_GAP;
		
		// SETUP LOOP
		loopButton = [UIButton buttonWithType:UIButtonTypeCustom];
		loopButton.frame = CGRectMake(0.0f, ypos, 45.0f, 45.0f);
		loopButton.tag = TRACKBUTTON_TAG + 3;
		[loopButton setImage:[UIImage imageNamed:@"loop-btn.png"] forState:UIControlStateNormal];
		[loopButton setImage:[UIImage imageNamed:@"loop-btn-inactive.png"] forState:UIControlStateDisabled];
		[loopButton setImage:[UIImage imageNamed:@"loop-btn-selected.png"] forState:UIControlStateSelected];
		[loopButton addTarget:self action:@selector(tappedTrackButton:) forControlEvents:UIControlEventTouchUpInside];
		
		loopBarView = [[UIView alloc] initWithFrame:
							  CGRectMake(loopButton.bounds.origin.x + loopButton.bounds.size.width + LAYOUT_GAP, 
										 ypos, 
										 273.0f, 
										 loopButton.bounds.size.height)];
		loopBarView.backgroundColor = RGBA(40, 40, 40, 1);
		loopBarView.tag = TRACKBAR_TAG + 3;
		ypos += loopButton.bounds.size.height - 5.0f;
		
		trackBarStart = sliderPos - (track1Button.bounds.origin.x + track1Button.bounds.size.width + LAYOUT_GAP) + 3.5f;
		
		// SETUP TIME SLIDER
		// Create slider background
		UIView *sliderBgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, ypos - 50, 300.0f, 12.0f)];
		sliderBgView.backgroundColor = [UIColor blackColor];
		
		UIImageView *ticker1 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 300.0f, 10.0f)];
		ticker1.image = [UIImage imageNamed:@"playhead-ticker.png"];
        ticker1.backgroundColor = [UIColor clearColor];
		[sliderBgView addSubview:ticker1];
        
		UIGraphicsBeginImageContext(sliderBgView.bounds.size);
		[sliderBgView.layer renderInContext:UIGraphicsGetCurrentContext()];
		UIImage *sliderBgImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		[ticker1 release];
		[sliderBgView release];
		ticker1 = nil;
		sliderBgView = nil;
		        
		timeSlider = [[UISlider alloc] initWithFrame:CGRectMake(sliderPos, ypos, 270.0f, 0.0f)];
		timeSlider.backgroundColor = [UIColor clearColor];        
		[timeSlider setThumbImage: [UIImage imageNamed:@"playhead.png"] forState:UIControlStateNormal];
		[timeSlider setThumbImage: [UIImage imageNamed:@"playhead.png"] forState:UIControlStateDisabled];
		[timeSlider setMinimumTrackImage:sliderBgImage forState:UIControlStateNormal];
		[timeSlider setMinimumTrackImage:sliderBgImage forState:UIControlStateDisabled];
		[timeSlider setMaximumTrackImage:sliderBgImage forState:UIControlStateNormal];
		[timeSlider setMaximumTrackImage:sliderBgImage forState:UIControlStateDisabled];
		timeSlider.minimumValue = TIMESLIDER_MIN;
		timeSlider.maximumValue = TIMESLIDER_MAX;
		timeSlider.continuous = YES;
		[timeSlider addTarget:self action:@selector(didMoveTimeSlider) forControlEvents:UIControlEventValueChanged];
		
		UIView *lineSliderIndicator = [[UIView alloc] initWithFrame:CGRectMake(sliderPos + (3.5f * (timeSlider.value + 1)), 105.0f, 
																	   7.0f, (track1Button.bounds.size.height + LAYOUT_GAP) * 4)];
		lineSliderIndicator.backgroundColor = [UIColor clearColor];
  
		UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(3.0f, 0.0f, 1.0f, (track1Button.bounds.size.height + LAYOUT_GAP) * 4)];
		lineView.backgroundColor = RGBA(255, 0, 0, 1);
		[lineSliderIndicator addSubview:lineView];
		UIGraphicsBeginImageContext(lineSliderIndicator.bounds.size);
		[lineSliderIndicator.layer renderInContext:UIGraphicsGetCurrentContext()];
		UIImage *lineSliderImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		[lineView release];
		[lineSliderIndicator release];
		lineView = nil;
		lineSliderIndicator = nil;
		
		UIView *clearView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 150.0f, 10.0f)];
		clearView.backgroundColor = [UIColor clearColor];
		UIGraphicsBeginImageContext(clearView.bounds.size);
		[clearView.layer renderInContext:UIGraphicsGetCurrentContext()];
		UIImage *clearImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		[clearView release];
		clearView = nil;
		
		timeSliderIndicator = [[UISlider alloc] initWithFrame:CGRectMake(sliderPos, 118.0f, 270.0f, 184.0f)];
		timeSliderIndicator.backgroundColor = [UIColor clearColor];
		[timeSliderIndicator setThumbImage: lineSliderImage forState:UIControlStateNormal];
		[timeSliderIndicator setThumbImage: lineSliderImage forState:UIControlStateDisabled];
		[timeSliderIndicator setMinimumTrackImage:clearImage forState:UIControlStateNormal];
		[timeSliderIndicator setMinimumTrackImage:clearImage forState:UIControlStateDisabled];
		[timeSliderIndicator setMaximumTrackImage:clearImage forState:UIControlStateNormal];
		[timeSliderIndicator setMaximumTrackImage:clearImage forState:UIControlStateDisabled];
		timeSliderIndicator.enabled = YES;
		timeSliderIndicator.minimumValue = TIMESLIDER_MIN;
		timeSliderIndicator.maximumValue = TIMESLIDER_MAX;
		timeSliderIndicator.continuous = YES;
		[timeSliderIndicator addTarget:self action:@selector(didMoveTimeSliderIndicator) forControlEvents:UIControlEventValueChanged];
		
		// Track Unit Multiplier
		//sliderPos += (float)timeSlider.currentThumbImage.size.width / (float) 2.0f;
		trackUnitMultiplier = (float)((float) timeSlider.bounds.size.width - (float) timeSlider.currentThumbImage.size.width) / (float) timeSlider.bounds.size.width;
		
		// SETUP ELAPSED TIME LABEL
		elapsedTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, ypos + 4.0f, 200.0f, 16.0f)];
		elapsedTimeLabel.backgroundColor = [UIColor clearColor];
		elapsedTimeLabel.font = [UIFont fontWithName:@"GrixelAcme7WideXtnd" size:8.0f];
		elapsedTimeLabel.textColor = RGBA(200, 200, 200, 1);
		
		ypos = 315.0f;		
		
		//-------------------------------------------------------------------
		// SETUP PLAYER BUTTONS
		
		rewindButton = [UIButton buttonWithType:UIButtonTypeCustom];
		rewindButton.frame = CGRectMake(0.0f, ypos, 79.25f, 100.0f);
		rewindButton.backgroundColor = RGBA(40, 40, 40, 1);
		[rewindButton setImage:[UIImage imageNamed:@"rwd-btn.png"] forState:UIControlStateNormal];
		[rewindButton setImage:[UIImage imageNamed:@"rwd-btn-selected.png"] forState:UIControlStateSelected];
		[rewindButton addTarget:self action:@selector(touchedUpInsideRewindButton:) forControlEvents:UIControlEventTouchUpInside];
		[rewindButton addTarget:self action:@selector(touchedDownRewindButton:) forControlEvents:UIControlEventTouchDown];
		
		rewindLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, rewindButton.bounds.size.height - 30.0f, rewindButton.bounds.size.width, 10.0f)];
		rewindLabel.backgroundColor = [UIColor clearColor];
		rewindLabel.font = [UIFont fontWithName:@"GrixelAcme7WideXtnd" size:8.0f];
		rewindLabel.textAlignment = UITextAlignmentCenter;
		rewindLabel.text = @"RWD";
		rewindLabel.textColor = RGBA(200, 200, 200, 1);
		[rewindButton addSubview:rewindLabel];
		
		playButton = [UIButton buttonWithType:UIButtonTypeCustom];
		playButton.frame = CGRectMake(80.25f, ypos, 79.25f, 100.0f);
		playButton.backgroundColor = RGBA(40, 40, 40, 1);
		[playButton setImage:[UIImage imageNamed:@"play-btn.png"] forState:UIControlStateNormal];
		[playButton setImage:[UIImage imageNamed:@"pause-btn-selected.png"] forState:UIControlStateSelected];
		[playButton addTarget:self action:@selector(tappedPlayButton:) forControlEvents:UIControlEventTouchUpInside];
		
		playLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, playButton.bounds.size.height - 30.0f, playButton.bounds.size.width, 10.0f)];
		playLabel.backgroundColor = [UIColor clearColor];
		playLabel.font = [UIFont fontWithName:@"GrixelAcme7WideXtnd" size:8.0f];
		playLabel.textAlignment = UITextAlignmentCenter;
		playLabel.text = @"PLAY";
		playLabel.textColor = RGBA(200, 200, 200, 1);
		[playButton addSubview:playLabel];
		
		fastForwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
		fastForwardButton.frame = CGRectMake(160.5f, ypos, 79.25f, 100.0f);
		fastForwardButton.backgroundColor = RGBA(40, 40, 40, 1);
		[fastForwardButton setImage:[UIImage imageNamed:@"ff-btn.png"] forState:UIControlStateNormal];
		[fastForwardButton setImage:[UIImage imageNamed:@"ff-btn-selected.png"] forState:UIControlStateSelected];
		[fastForwardButton addTarget:self action:@selector(touchedUpInsideForwardButton:) forControlEvents:UIControlEventTouchUpInside];
		[fastForwardButton addTarget:self action:@selector(touchedDownForwardButton:) forControlEvents:UIControlEventTouchDown];
	
		fastForwardLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, fastForwardButton.bounds.size.height - 30.0f, fastForwardButton.bounds.size.width, 10.0f)];
		fastForwardLabel.backgroundColor = [UIColor clearColor];
		fastForwardLabel.font = [UIFont fontWithName:@"GrixelAcme7WideXtnd" size:8.0f];
		fastForwardLabel.textAlignment = UITextAlignmentCenter;
		fastForwardLabel.text = @"FF";
		fastForwardLabel.textColor = RGBA(200, 200, 200, 1);
		[fastForwardButton addSubview:fastForwardLabel];
		
		recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
		recordButton.frame = CGRectMake(240.75f, ypos, 79.25f, 100.0f);
		recordButton.backgroundColor = RGBA(40, 40, 40, 1);
		[recordButton setImage:[UIImage imageNamed:@"rec-btn.png"] forState:UIControlStateNormal];
		[recordButton setImage:[UIImage imageNamed:@"rec-btn-inactive.png"] forState:UIControlStateDisabled];
		[recordButton setImage:[UIImage imageNamed:@"rec-btn-selected.png"] forState:UIControlStateSelected];
		[recordButton addTarget:self action:@selector(tappedRecordButton:) forControlEvents:UIControlEventTouchUpInside];
		
		recordLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, recordButton.bounds.size.height - 30.0f, recordButton.bounds.size.width, 10.0f)];
		recordLabel.backgroundColor = [UIColor clearColor];
		recordLabel.font = [UIFont fontWithName:@"GrixelAcme7WideXtnd" size:8.0f];
		recordLabel.textAlignment = UITextAlignmentCenter;
		recordLabel.text = @"REC";
		recordLabel.textColor = RGBA(200, 200, 200, 1);
		[recordButton addSubview:recordLabel];
		
		[self addSubview:rewindButton];
		[self addSubview:playButton];
		[self addSubview:fastForwardButton];
		[self addSubview:recordButton];
		
		[self addSubview:bgView];
		[self addSubview:blackView];
		[self addSubview:instrumentView];
		[self addSubview:instrumentScrollView];
		
		[self addSubview:track1Button];
		[self addSubview:track1BarView];
		[self addSubview:track2Button];
		[self addSubview:track2BarView];
		[self addSubview:track3Button];
		[self addSubview:track3BarView];
		[self addSubview:loopButton];
		[self addSubview:loopBarView];
		
		[self addSubview:timeSlider];
		[self addSubview:timeSliderIndicator];
		[self addSubview:elapsedTimeLabel];
		
		[bgView release];
		[blackView release];
		[instrumentView release];
		
		// SETUP INSTRUMENT INDICATORS
		float circleSize = 20.0f;	// circle diameter + gap
		float circleStart = instrumentScrollView.bounds.origin.x - 30.0f + ((float)instrumentScrollView.bounds.size.width / (float)2.0f) - ((float)((circleSize * [instrumentArray count]) - 10.0f) / (float)2.0f);
		int i;
		for(i = 0; i < 6; ++i)
		{
			// Set instrument indicator
			CircleView *circle = [[CircleView alloc] initWithFrame:CGRectMake(circleStart, 105.0f, circleSize, 10.0f)];
			circle.tag = CIRCLE_TAG + i;
			[self addSubview:circle];
			
			[circle release];
			circle = nil;
			circleStart += circleSize;
		}
		
		//-------------------------------------------------------------------
		recordedMicArray = [[NSMutableArray alloc] init];
		
		// SETUP ALERT
		notRecordedAlert = [[UIAlertView alloc] initWithTitle:nil 
													   message:@"None of the tracks have been recorded." 
														delegate:self 
											   cancelButtonTitle:@"OK" 
											   otherButtonTitles:nil];
        noDrumBeatsAlert = [[UIAlertView alloc] initWithTitle:nil 
                                                      message:@"No drum beat has been created." 
                                                     delegate:self 
                                            cancelButtonTitle:@"OK" 
                                            otherButtonTitles:nil];
        
    }
    return self;
}


-(void) fillInViewValues
{
	int i;
		
	// Song Name
	songNameTextField.text = songName;

	// Instrument Scroll View
	for(UIView *subview in [instrumentScrollView subviews]) 
		[subview removeFromSuperview];
	instrumentScrollView.contentSize = CGSizeMake(instrumentScrollView.bounds.size.width * [instrumentArray count], 30.0f);
	InstrumentObject *anInstrumentObject;
	
	for(i = 0; i < [instrumentArray count]; ++i)
	{
		anInstrumentObject = [instrumentArray objectAtIndex:i];
		
		UIButton *instrumentButton = [UIButton buttonWithType:UIButtonTypeCustom];
		instrumentButton.frame = CGRectMake((instrumentScrollView.bounds.size.width * i), 0.0f, instrumentScrollView.bounds.size.width, 40.0f);
		[instrumentButton setTitle:anInstrumentObject.name forState:UIControlStateNormal];
		instrumentButton.titleLabel.font = [UIFont fontWithName:@"GrixelAcme7Wide" size:24.0f];
		instrumentButton.backgroundColor = [UIColor clearColor];
		[instrumentButton setTitleColor:RGBA(200, 200, 200, 1) forState:UIControlStateNormal];
		[instrumentButton addTarget:self action:@selector(tappedInstrument) forControlEvents:UIControlEventTouchUpInside];
		[instrumentScrollView addSubview:instrumentButton];
		
		UILabel *instrumentDesc = [[UILabel alloc] initWithFrame:CGRectMake((instrumentScrollView.bounds.size.width * i), 35.0f, instrumentScrollView.bounds.size.width, 10.0f)];
		instrumentDesc.text = anInstrumentObject.description;
		instrumentDesc.textAlignment = UITextAlignmentCenter;
		instrumentDesc.textColor = RGBA(80, 80, 80, 1);
		instrumentDesc.font = [UIFont fontWithName:@"GrixelAcme7WideXtnd" size:8.0f];
		instrumentDesc.backgroundColor = [UIColor clearColor];
		[instrumentScrollView addSubview:instrumentDesc];
		[instrumentDesc release];
		instrumentDesc = nil;
	}
	
	// Set to selected instrument
	CGPoint offsetPoint = CGPointMake((instrument * instrumentScrollView.bounds.size.width), instrumentScrollView.contentOffset.y);
	[instrumentScrollView setContentOffset:offsetPoint];
	CircleView *selectedCircle = (CircleView *)[self viewWithTag:CIRCLE_TAG + instrument];
	[selectedCircle setAsSelected];
	
	// Set track buttons state and track bars
	TrackObject *aTrackObject;
	for(i = 0; i < [trackObjectArray count]; i++)
	{
		aTrackObject = [trackObjectArray objectAtIndex:i];
		if(trackNumber == i)	// Selected track number
		{
			UIButton *btn = (UIButton *)[self viewWithTag:TRACKBUTTON_TAG + i];
			btn.selected = YES;
		}
	
		// Track Bar
		UIView *currTrackBar = (UIView *)[self viewWithTag:TRACKBAR_TAG + i];
		
		// Remove previous bars
		for(UIView *subView in [currTrackBar subviews])
			[subView removeFromSuperview];
		
		// Show recorded bars
		if(aTrackObject.isRecorded == YES)
		{
			NSMutableString *sub = [[NSMutableString alloc] initWithString:[NSMutableString stringWithFormat:@"%@", aTrackObject.recordFlags]];
			int start, index = 0, len;
			while(YES)
			{
				// Search for start of recording
				start = [sub rangeOfString:@"1"].location;
				index += start;
				if(start == NSNotFound)
				{
					break;
				}
				
				sub = (NSMutableString*)[sub substringFromIndex:start];
				
				// Search for end of recording
				len = [sub rangeOfString:@"0"].location;
				if(len == NSNotFound)			
				{
					len = [sub length];
				}
				
				// Add track bar
				UIView *trackBar = [[UIView alloc] init];
				float start = trackBarStart + (index * trackUnitMultiplier);
				trackBar.frame = CGRectMake(start, 0.0f, len * trackUnitMultiplier, track1Button.bounds.size.height);
				if(trackNumber == i)
					trackBar.backgroundColor = RGBA(255, 255, 0, 1);
				else
					trackBar.backgroundColor = RGBA(117, 128, 0, 0.25);
				[currTrackBar addSubview:trackBar];
				[trackBar release];
								
				if(len == [sub length])
				{
					break;
				}
				sub = (NSMutableString*)[sub substringFromIndex:len];
				index += len;
			}
		}		
	}
	
	// Time Slider
	timeSlider.value = (elapsedMin * 60.0f) + elapsedSec;	
	timeSliderIndicator.value = timeSlider.value;
	//elapsedTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d / %02d:%02d", elapsedMin, elapsedSec, (int)RECORDING_MINUTES, (int)RECORDING_SECONDS];
    elapsedTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", elapsedMin, elapsedSec];
    
    tempoTimeInterval = (float) 60.0f / (float) tempo;
}

//-----------------------------------------------------------------------------------
// NAVIGATION BUTTONS
-(void) tappedClearButton:(id) sender
{
	UIActionSheet *clearActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" 
												   destructiveButtonTitle:@"Clear Track" 
														otherButtonTitles:nil];
	clearActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[clearActionSheet showInView:self];
	[clearActionSheet release];
	clearActionSheet.tag = CLEARSONGAS_TAG;
	clearActionSheet = nil;
}

-(void) tappedSaveButton:(id) sender
{
	onSaveMode = YES;
	
	// Dim background
	UIView *dimBgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f)];
	dimBgView.backgroundColor = RGBA(0, 0, 0, 0.75);
	dimBgView.tag = 700;
	[self addSubview:dimBgView];
	songNameTextField.backgroundColor = RGBA(40, 40, 40, 1);
	[dimBgView addSubview:songNameTextField];
	[dimBgView release];
	
	[songNameTextField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	
	UIView *bgView = (UIView *)[self viewWithTag:700];
	[bgView removeFromSuperview];
	songNameTextField.backgroundColor = RGBA(80, 80, 80, 1);
	[self addSubview:songNameTextField];
	
	// Replace current song
	if(songID != -1 && ([songName compare:songNameTextField.text] == NSOrderedSame))
	{
		[nc postNotificationName:@"didReplaceSong" object:nil];	
	}
	// Save new version of song
	else 
	{
		songName = textField.text;
		[nc postNotificationName:@"didSaveNewSongWithName" object:songName];
	}
	
	onSaveMode = NO;
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if(onSaveMode == NO)
	{
		[textField resignFirstResponder];
	}
}

//-----------------------------------------------------------------------------------
// SCROLL VIEW IMPLEMENTATION

-(void) tappedInstrument
{
	// On double tap, open Record Beat screen
	if(trackNumber == ([trackObjectArray count] - 1) && ([instrumentArray count] - 1))
	{
		// Detect double tap
		if(prevInstrumentTapTime == nil)
		{
			prevInstrumentTapTime = [[NSDate date] retain];
		}
		else 
		{
			if([[NSDate date] timeIntervalSinceDate:prevInstrumentTapTime] <= 0.5f)
			{
				[nc postNotificationName:@"didSelectRecordNewBeat" object:nil];
			}
			prevInstrumentTapTime = [[NSDate date] retain];
		}
	}
}

-  (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	int prevInstrument = instrument;
	
	CGRect visibleInstrumentRect;
	visibleInstrumentRect.origin = instrumentScrollView.contentOffset;
	visibleInstrumentRect.size = instrumentScrollView.bounds.size;	
	instrument = visibleInstrumentRect.origin.x / visibleInstrumentRect.size.width;	
	
	// Update indicator
	CircleView *prevCircle = (CircleView *)[self viewWithTag:CIRCLE_TAG + prevInstrument];
	[prevCircle setAsNotSelected];
	CircleView *circle = (CircleView *)[self viewWithTag:CIRCLE_TAG + instrument];
	[circle setAsSelected];
    
    if((instrument == ([instrumentArray count] - 1) && trackNumber != ([trackObjectArray count] - 1)) ||
       (instrument != ([instrumentArray count] - 1) && trackNumber == ([trackObjectArray count] - 1))) 
	{
		recordButton.enabled = NO;
		recordLabel.textColor = RGBA(120, 120, 120, 1);
	}
	else
	{
		recordButton.enabled = YES;
		recordLabel.textColor = RGBA(200, 200, 200, 1);
	}
}

//-----------------------------------------------------------------------------------
// TRACK BUTTONS
-(void) tappedTrackButton:(id) sender
{
	UIButton *btn = (UIButton*) sender;
	int currTrackNumber = btn.tag % TRACKBUTTON_TAG;
	
	// Deselect previous track number
	UIButton *prevBtn = (UIButton *)[self viewWithTag:(TRACKBUTTON_TAG + trackNumber)];
	prevBtn.selected = NO;
	UIView *prevTrackBar = (UIView *)[self viewWithTag:TRACKBAR_TAG + trackNumber];
	for(UIView *subview in [prevTrackBar subviews]) 
		subview.backgroundColor = RGBA(117, 128, 0, 0.25);
	
	// Select current track number
	btn.selected = YES;
	UIView *currTrackBar = (UIView *)[self viewWithTag:TRACKBAR_TAG + currTrackNumber];
	for(UIView *subview in [currTrackBar subviews]) 
		subview.backgroundColor = RGBA(255, 255, 0, 1);
	
    // Cannot record from voice and sounds on track 4
    if((currTrackNumber == ([trackObjectArray count] - 1) && instrument != [instrumentArray count] - 1) ||
        (currTrackNumber != ([trackObjectArray count] - 1) && instrument == [instrumentArray count] - 1))
    {
        recordButton.enabled = NO;
        recordLabel.textColor = RGBA(120, 120, 120, 1);
    }
    else if((currTrackNumber != ([trackObjectArray count] - 1) && instrument != [instrumentArray count] - 1) ||
            (currTrackNumber == ([trackObjectArray count] - 1) && instrument == [instrumentArray count] - 1))
    {
        recordButton.enabled = YES;
        recordLabel.textColor = RGBA(200, 200, 200, 1);
    }

	trackNumber = currTrackNumber;
	
	[nc postNotificationName:@"didChangeTrackNumber" object:[NSNumber numberWithInt:trackNumber]];
}

//-----------------------------------------------------------------------------------
// REWIND BUTTON IMPLEMENTATION
-(void) touchedDownRewindButton:(id) sender
{
	buttonMode = buttonStalling;
	[self performSelector:@selector(tryRewindScan) withObject:nil afterDelay:1.0];
}

-(void) touchedUpInsideRewindButton:(id) sender
{	
	if(buttonMode == buttonScanningRew)
	{
		[self stopRewindScan];
	}
	else if(buttonMode == buttonStalling)
	{
		// Normal rewind behavior
		timeSlider.value -= SKIP_TIME;
		[timeSlider sendActionsForControlEvents:UIControlEventValueChanged];
	}
	buttonMode = buttonIdle;
}

-(void) tryRewindScan
{
	if(buttonMode == buttonStalling)
	{
		buttonMode = buttonScanningRew;
		[self startRewindScan];
	}
}

-(void) startRewindScan
{
	rewTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(didPlayMoveTimeSlider) userInfo:nil repeats:YES];
}

-(void) stopRewindScan
{	
	[rewTimer invalidate];
}

//-----------------------------------------------------------------------------------
// FAST FORWARD BUTTON IMPLEMENTATION
-(void) touchedDownForwardButton:(id) sender
{
	buttonMode = buttonStalling;
	[self performSelector:@selector(tryForwardScan) withObject:nil afterDelay:1.0];
}

-(void) touchedUpInsideForwardButton:(id) sender
{	
	if(buttonMode == buttonScanningFwd)
	{
		[self stopForwardScan];
	}
	else if(buttonMode == buttonStalling)
	{
		// Normal forward behavior
		timeSlider.value += SKIP_TIME;
		[timeSlider sendActionsForControlEvents:UIControlEventValueChanged];
	}
	buttonMode = buttonIdle;
}

-(void) tryForwardScan
{
	if(buttonMode == buttonStalling)
	{
		buttonMode = buttonScanningFwd;
		[self startForwardScan];
	}
}

-(void) startForwardScan
{
	fwdTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(didPlayMoveTimeSlider) userInfo:nil repeats:YES];
}

-(void) stopForwardScan
{	
	[fwdTimer invalidate];
}

//-----------------------------------------------------------------------------------
// PLAY IMPLEMENTATION
-(void) tappedPlayButton:(id) sender
{
	if(isPlayMode == YES)
	{
		isPlayMode = NO;
		[self pausePlayer];
	}
	else
	{
		[self startPlayer];
	}
}

-(void) startPlayer
{
    beatCounter = 0;    // Monitor drum beats
    
    //ROUTE TO BOTTOM SPEAKER ON PLAY
    UInt32 ASRoute = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (
                             kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (ASRoute),
                             &ASRoute
                             );   
    
	// Check if a track has been recorded
    TrackObject *aTrackObject;
    BOOL hasFoundRecorded = NO;
    
    for(int i = 0; i < [trackObjectArray count]; i++)
    {
        aTrackObject = [trackObjectArray objectAtIndex:i];
        if(aTrackObject.isRecorded == YES)
        {
            hasFoundRecorded = YES;
            break;
        }
    }
    
    if(hasFoundRecorded)
    {
        isPlayMode = YES;
		hasReachedEnd = NO;
        
        // Play non-drum tracks
        playTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(didPlayMoveTimeSlider) userInfo:nil repeats:YES];
        
        // Play drum track
        if([[trackObjectArray objectAtIndex:DRUM_TRACK] isRecorded])
            playDrumsTimer = [NSTimer scheduledTimerWithTimeInterval:tempoTimeInterval target:self selector:@selector(didPlayDrums) userInfo:nil repeats:YES];

        [self updatePlayControlState:YES];
    }
    else
    {
        [notRecordedAlert show];	// Show alert that none of the tracks has been recorded
    }   
}

-(void) pausePlayer
{
    if(playTimer != nil)
        [playTimer invalidate];
    if(playDrumsTimer != nil)
        [playDrumsTimer invalidate];
    
    // Stop all track players
    for(int i = 0; i < ([trackObjectArray count] - 1); i++)
    {
        TrackObject *aTrackObject = [trackObjectArray objectAtIndex:i];
        if(aTrackObject.isRecorded == YES && [aTrackObject.player isPlaying])
            [aTrackObject.player stop];
    }
    [self updatePlayControlState:NO];
	[self sendTimeSliderNotification];
}

-(void) stopPlayer
{
	if(buttonMode == buttonScanningFwd)		
		[self stopForwardScan];
	else if(buttonMode == buttonScanningRew)
		[self stopRewindScan];
	
	buttonMode = buttonIdle;
	timeSlider.value = 0;
	isPlayMode = NO;
    
    if(playTimer != nil)
        [playTimer invalidate];
    if(playDrumsTimer != nil)
        [playDrumsTimer invalidate];
	
	// Stop all track players
    for(int i = 0; i < ([trackObjectArray count] - 1); i++)
    {
        TrackObject *aTrackObject = [trackObjectArray objectAtIndex:i];
        if(aTrackObject.isRecorded == YES && [aTrackObject.player isPlaying])
            [aTrackObject.player stop];
    }
	
    [self updatePlayControlState:NO];
	[timeSlider sendActionsForControlEvents:UIControlEventValueChanged];
	[self sendTimeSliderNotification];
}

//-----------------------------------------------------------------------------------
// PLAY TIME SLIDERS
// Play non-drum tracks
-(void) didPlayMoveTimeSlider
{
	if(hasReachedEnd == YES)
	{
		[self stopPlayer];
		return;
	}
	
	if(buttonMode == buttonScanningFwd)
		timeSlider.value += SKIP_TIME;
	else if(buttonMode == buttonScanningRew)
		timeSlider.value -= SKIP_TIME;
	else 
		timeSlider.value += 1.0;
	
    for(int i = 0; i < ([trackObjectArray count] - 1); i++)
    {
        TrackObject *aTrackObject = [trackObjectArray objectAtIndex:i];
        
        if(aTrackObject.isRecorded == YES)
        {
            int flag = [[aTrackObject.recordFlags substringWithRange:NSMakeRange((int)timeSlider.value, 1)] intValue];
            if(flag == NOTRECORDED_FLAG)
            {
                [aTrackObject.player stop];
                [aTrackObject.player setCurrentTime:0.0];
            }
            else if([aTrackObject.player isPlaying] == NO)
            {
                NSLog(@"URL %@ duration %d", [aTrackObject.player url], (int)[aTrackObject.player duration]);
                
                // Get position of player based on the slider position
                int posSlider = (int)timeSlider.value - 1.0f;
                int posFlag;            // Flag atposSlider position
                float posPlayer = 0.0;
                
                while(posSlider >= 0.0)
                {
                    posFlag = [[aTrackObject.recordFlags substringWithRange:NSMakeRange((int)posSlider, 1)] intValue];
                    if(posFlag == NOTRECORDED_FLAG || posSlider == 0.0)
                    {
                        posPlayer = ((int)(timeSlider.value - posSlider) % (int)[aTrackObject.player duration]) - 1;                            
                        break;
                    }
                    posSlider--;
                }
                
                if(aTrackObject.instrument == 0)
                {
                    AVAudioPlayer *currPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[aTrackObject.player url] error:nil];
                    
                    aTrackObject.player = currPlayer;
                    [aTrackObject.player setCurrentTime:posPlayer];
                    [aTrackObject.player play];
                }
                else
                {
                    [aTrackObject.player setCurrentTime:posPlayer];
                    [aTrackObject.player play];
                }
            }
            else
            {
                [aTrackObject.player play];
            }
        }
    }
    // End of playing recorded tracks
  
	if((int)timeSlider.value == (int)timeSlider.maximumValue)
		hasReachedEnd = YES;

	[timeSlider sendActionsForControlEvents:UIControlEventValueChanged];
}

// Play drum track
-(void) didPlayDrums
{
    TrackObject *aTrackObject = [trackObjectArray objectAtIndex:DRUM_TRACK];
    int flag = [[aTrackObject.recordFlags substringWithRange:NSMakeRange((int)timeSlider.value, 1)] intValue];
    
    if(aTrackObject.isRecorded == YES && flag == RECORDED_FLAG)
    {
        int index = [[aTrackObject.drumPadArray objectAtIndex:beatCounter] intValue];
        if(index != -1)
        {
            InstrumentObject *anInstrumentObject = [drumKitArray objectAtIndex:index];
            AVAudioPlayer *drumPlayer = [[AVAudioPlayer alloc] 
                                         initWithContentsOfURL:[NSURL 
                                                                fileURLWithPath:[[NSBundle mainBundle] 
                                                                                 pathForResource:[NSString stringWithFormat:@"%@", anInstrumentObject.fileName] 
                                                                                 ofType:[NSString stringWithFormat:@"%@", anInstrumentObject.extensionType]]]
                                         error:nil];
            [drumPlayer setVolume:aTrackObject.volumeLevel];
            [drumPlayer setDelegate:self];
            [drumPlayer play];
        }
        ++beatCounter;
        
        if(beatCounter == loopLength)
            beatCounter = 0;
    }
}

-(void) didMoveTimeSlider
{    
    if (elapsedMin != RECORDING_MINUTES) 
    {
        elapsedMin = (int)[timeSlider value] / 60;
        elapsedSec = (int)[timeSlider value] % 60;
        //elapsedTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d / %02d:%02d", elapsedMin, elapsedSec, (int)RECORDING_MINUTES, (int)RECORDING_SECONDS];
        elapsedTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", elapsedMin, elapsedSec];
        timeSliderIndicator.value = timeSlider.value;
    }
    else
    {
        [self stopPlayer];
    }
}

-(void) didMoveTimeSliderIndicator
{    
	timeSlider.value = timeSliderIndicator.value;
	elapsedMin = (int)[timeSlider value] / 60;
	elapsedSec = (int)[timeSlider value] % 60;
	//elapsedTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d / %02d:%02d", elapsedMin, elapsedSec, (int)RECORDING_MINUTES, (int)RECORDING_SECONDS];
    elapsedTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", elapsedMin, elapsedSec];
}

-(void) sendTimeSliderNotification
{
	NSDictionary *timeDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithInt:elapsedMin], @"elapsedMin",
							  [NSNumber numberWithInt:elapsedSec], @"elapsedSec",
							  nil];
	[nc postNotificationName:@"didMoveRecordingTimeSlider" object:timeDict];
}

//-----------------------------------------------------------------------------------
// RECORD IMPLEMENTATION
-(void) tappedRecordButton:(id) sender
{
	if(timeSlider.value != timeSlider.maximumValue)
	{
		if(isRecordMode == YES)
		{
			isRecordMode = NO;
			[self stopRecorder];
		}
        // Check if a drum beat has been recorded
        else if(trackNumber == DRUM_TRACK &&
                instrument == [instrumentArray count] - 1 &&
                [[trackObjectArray objectAtIndex:DRUM_TRACK] isRecorded] == NO)
        {
            [noDrumBeatsAlert show];
        }
		else 
		{
			isRecordMode = YES;
			[self startRecorder];
		}
	}	
}

-(void) startRecorder
{ 
    
	// Set time slider
	timeSlider.maximumValue = TIMESLIDER_MAX;
	
	InstrumentObject *anInstrumentObject;
    anInstrumentObject = [instrumentArray objectAtIndex:instrument];
    
	if(trackNumber != DRUM_TRACK) // Not a drum loop track
    {
        // Recording from Mic
        if ([anInstrumentObject.fileName isEqualToString:@"Mic"])
        {
            isMicRecording = YES;
            
            // Establish recorder
            if (!self.micRecording) 
            {
                self.micRecording = [[[MicRecording alloc] init] autorelease];
                
                micRecordingAlert = [[[UIAlertView alloc] initWithTitle:@"MIC RECORDING IN PROGRESS"
                                                                message:@""
                                                               delegate:self 
                                                      cancelButtonTitle:@"Stop"
                                                      otherButtonTitles:nil] autorelease];
                
                // Hook the level meter up to the Audio Queue for the recorder			
                lvlMeter_in = [[AQLevelMeter alloc] initWithFrame:CGRectMake(20.0f, 60.0f, 490.0f, 20.0f)];
                UIColor *bgColor = [[UIColor alloc] initWithRed:.39 green:.44 blue:.57 alpha:.5];
                [lvlMeter_in setBackgroundColor:bgColor];
                [lvlMeter_in setBorderColor:bgColor];
                [bgColor release];
                
                [micRecordingAlert addSubview:lvlMeter_in];
                [micRecordingAlert show];
                
                //ROUTE TO TOP SPEAKER ON RECORD
                UInt32 ASRoute = kAudioSessionOverrideAudioRoute_None;
                AudioSessionSetProperty (
                                         kAudioSessionProperty_OverrideAudioRoute,
                                         sizeof (ASRoute),
                                         &ASRoute
                                         );  
            }
            
            if (self.micRecording)
            {
                NSString *filePath = FILEPATH;
                BOOL success = [self.micRecording startRecording:filePath];
                
                [lvlMeter_in setAq:micRecording.audioQueue];
                
                recorderURL = [[NSURL fileURLWithPath:filePath] retain];
                
                NSLog(@"url %@", recorderURL);
                
                if (!success)
                {
                    printf("Error starting recording\n");
                    [self.micRecording stopRecording];
                    self.micRecording = nil;
                    isMicRecording = NO;
                }
            }
            else
            {
                NSLog(@"Error: Could not create recorder");
                [self.micRecording stopRecording];
                self.micRecording = nil;
            }   
        }
        // Recording from an existing sound file
        else
        {
            recorderURL = [[NSURL fileURLWithPath:[[NSBundle mainBundle] 
                                                   pathForResource:[NSString stringWithFormat:@"%@", anInstrumentObject.fileName] 
                                                   ofType:[NSString stringWithFormat:@"%@", anInstrumentObject.extensionType]]] retain];
            
            //ROUTE TO BOTTOM SPEAKER ON RECORD MUSIC FILE
            UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
            AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
        }
        
        TrackObject *aTrackObject = [trackObjectArray objectAtIndex:trackNumber];
        [aTrackObject setPlayer:[[AVAudioPlayer alloc] initWithContentsOfURL:recorderURL error:nil]];
        [aTrackObject setVolumeLevel:1.0f];
        [aTrackObject setIsRecorded:YES];    
        [aTrackObject setTrackSoundFile: [NSString stringWithFormat:@"%@",recorderURL]];
        [trackObjectArray replaceObjectAtIndex:trackNumber withObject:aTrackObject];          
    }
        
	recordStart = timeSlider.value;
	    
    if (self.micRecording ==NO)
    {
    // Metronome
	if(isRecordInstrument)
        metronomeTimer = [NSTimer scheduledTimerWithTimeInterval:tempoTimeInterval target:self selector:@selector(didRecordWithMetronome) userInfo:nil repeats:YES];
    }
    
    // Non-drum tracks
    recTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(didRecordMoveTimeSlider) userInfo:nil repeats:YES];
    
    // Drum track
    if([[trackObjectArray objectAtIndex:DRUM_TRACK] isRecorded])
    {
        beatCounter = 0;
        recDrumsTimer = [NSTimer scheduledTimerWithTimeInterval:tempoTimeInterval target:self selector:@selector(didRecordDrums) userInfo:nil repeats:YES];
    }
    
    [self updateRecordControlState:NO];
}

-(void) didRecordWithMetronome
{
    AVAudioPlayer *metronomePlayer = [[AVAudioPlayer alloc] 
                                 initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"tick" ofType:@"caf"]]
                                 error:nil];
    [metronomePlayer setDelegate:self];
    [metronomePlayer play];
}

-(void) didRecordDrums
{
    TrackObject *aTrackObject = [trackObjectArray objectAtIndex:DRUM_TRACK];
    int flag = [[aTrackObject.recordFlags substringWithRange:NSMakeRange((int)timeSlider.value, 1)] intValue];
    
    if(trackNumber == DRUM_TRACK || (trackNumber != DRUM_TRACK && flag == RECORDED_FLAG))
    {
        int index = [[aTrackObject.drumPadArray objectAtIndex:beatCounter] intValue];
        if(index != -1)
        {
            InstrumentObject *anInstrumentObject = [drumKitArray objectAtIndex:index];
            AVAudioPlayer *drumPlayer = [[AVAudioPlayer alloc] 
                                         initWithContentsOfURL:[NSURL 
                                                                fileURLWithPath:[[NSBundle mainBundle] 
                                                                                 pathForResource:[NSString stringWithFormat:@"%@", anInstrumentObject.fileName] 
                                                                                 ofType:[NSString stringWithFormat:@"%@", anInstrumentObject.extensionType]]]
                                         error:nil];
            [drumPlayer setDelegate:self];
            [drumPlayer play];
        }
        ++beatCounter;
        
        if(beatCounter == loopLength)
            beatCounter = 0;
    }
}

- (void) stopRecorder
{	
	NSLog(@"url stopRecorder %@", recorderURL);
	
    // Invalidate timers
    if(recTimer != nil)
        [recTimer invalidate];
    if(recDrumsTimer != nil)
        [recDrumsTimer invalidate];
    
    if (isMicRecording == NO)
    {
        if(metronomeTimer != nil)
            [metronomeTimer invalidate];
    }
    
    
	if (self.micRecording)
	{
		[micRecording release];
		micRecording = nil;		
		isMicRecording = NO;		
		
		[recordedMicArray addObject:recorderURL];	
		
		[lvlMeter_in setAq: nil];
        NSLog(@"Recording from mic");
	}
    

    // Stop all track players
    TrackObject *aTrackObject;
    
    if (trackObjectArray != nil || [trackObjectArray count] > 0)
    {
        for(int i = 0; i < ([trackObjectArray count] - 1); i++)
        {
            aTrackObject = [trackObjectArray objectAtIndex:i];
            if(aTrackObject.isRecorded == YES && [aTrackObject.player isPlaying])
            {
                [aTrackObject.player stop];
                [aTrackObject.player setCurrentTime:0.0];
            }
        }
    }
    
	recordEnd = (int)timeSlider.value - 1;
	isRecordMode = NO;
	
	// Update the track object
	aTrackObject = [trackObjectArray objectAtIndex:trackNumber];
	aTrackObject.volumeLevel = 1.0f;
	aTrackObject.pitchLevel = 0.0f;
	aTrackObject.instrument = instrument;
    
    // Recording from mic
    if(instrument == 0) 
    {
        aTrackObject.recordedItems++;
        [aTrackObject.recordedMicArray addObject:recorderURL];
        NSLog(@"array count %d", [aTrackObject.recordedMicArray count]);
        NSLog(@"recordedItems %d", aTrackObject.recordedItems);
    }
	
	[self updateRecordFlags];
	[trackObjectArray replaceObjectAtIndex:trackNumber withObject:aTrackObject];
    
    [self updateRecordControlState:YES];	
	NSDictionary *trackDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  aTrackObject, @"trackObject",
							  [NSNumber numberWithInt:trackNumber], @"trackNumber",
							  nil];
	[nc postNotificationName:@"didUpdateTrack" object:trackDict];
	[self sendTimeSliderNotification];
}

-(void) updateRecordFlags
{
	TrackObject *aTrackObject = [trackObjectArray objectAtIndex:trackNumber];

    int length = (recordEnd - recordStart) + 1;
	
	if(recordStart != 0)
		length++;
	
	NSRange range = NSMakeRange(recordStart, length);
    
	NSString *sub = [aTrackObject.recordFlags substringWithRange:range];
	NSString *newSub = [sub stringByReplacingOccurrencesOfString:@"0" withString:@"1"];
	[aTrackObject setRecordFlags:(NSMutableString*)[aTrackObject.recordFlags stringByReplacingCharactersInRange:range withString:newSub]];	
}

-(void) updatePlayControlState:(BOOL) isPlaying
{
    clearButton.enabled = !isPlaying;
    saveButton.enabled = !isPlaying;
    instrumentScrollView.scrollEnabled = !isPlaying;		
    playButton.selected = isPlaying;
    recordButton.enabled = !isPlaying;

    for(int i = 0; i < [trackObjectArray count]; i++)
    {
        if(i != trackNumber)
        {
            UIButton *btn = (UIButton *)[self viewWithTag:TRACKBUTTON_TAG + i];
            btn.enabled = !isPlaying;
        }
    }
    
    // Set state of controls
    if(isPlaying)
    {
        clearLabel.textColor = RGBA(120, 120, 120, 1);
        saveLabel.textColor = RGBA(120, 120, 120, 1);
        playLabel.text = @"PAUSE";
        playLabel.textColor = RGBA(200, 200, 200, 1);
        recordLabel.textColor = RGBA(120, 120, 120, 1);
        
        [nc postNotificationName:@"didDisableRecordingTabBar" object:nil];
        [nc postNotificationName:@"didDisableTracksTabBar" object:nil];
        [nc postNotificationName:@"didDisableSongsTabBar" object:nil];
        [nc postNotificationName:@"didDisableSettingsTabBar" object:nil];
    }
    else
    {   
        clearLabel.textColor = RGBA(200, 200, 200, 1);
        saveLabel.textColor = RGBA(200, 200, 200, 1);
        playLabel.text = @"PLAY";
        playLabel.textColor = RGBA(120, 120, 120, 1);
        recordLabel.textColor = RGBA(200, 200, 200, 1);
 
        [nc postNotificationName:@"didEnableRecordingTabBar" object:nil];
        [nc postNotificationName:@"didEnableTracksTabBar" object:nil];
        [nc postNotificationName:@"didEnableSongsTabBar" object:nil];
        [nc postNotificationName:@"didEnableSettingsTabBar" object:nil];
    }
}
- (void) updateRecordControlState:(BOOL) isRecording
{
    // Set state of controls
	clearButton.enabled = isRecording;
	saveButton.enabled = isRecording;
	instrumentScrollView.scrollEnabled = isRecording;
	playButton.enabled = isRecording;
	rewindButton.enabled = isRecording;
	fastForwardButton.enabled = isRecording;
	recordButton.selected = !isRecording;
	timeSlider.enabled = isRecording;
	timeSliderIndicator.enabled = isRecording;
    
    for(int i = 0; i < [trackObjectArray count]; i++)
	{
		if(i != trackNumber)
		{
			UIButton *btn = (UIButton *)[self viewWithTag:TRACKBUTTON_TAG + i];
			btn.enabled = isRecording;
		}
	}
    
    if(isRecording)
    {
        clearLabel.textColor = RGBA(200, 200, 200, 1);
        saveLabel.textColor = RGBA(200, 200, 200, 1);
        playLabel.textColor = RGBA(200, 200, 200, 1);
        rewindLabel.textColor = RGBA(200, 200, 200, 1);
        fastForwardLabel.textColor = RGBA(200, 200, 200, 1);
        recordLabel.textColor = RGBA(200, 200, 200, 1);
        
        [nc postNotificationName:@"didEnableRecordingTabBar" object:nil];
        [nc postNotificationName:@"didEnableTracksTabBar" object:nil];
        [nc postNotificationName:@"didEnableSongsTabBar" object:nil];
        [nc postNotificationName:@"didEnableSettingsTabBar" object:nil];
    }
    else
    {
        clearLabel.textColor = RGBA(120, 120, 120, 1);
        saveLabel.textColor = RGBA(120, 120, 120, 1);
        playLabel.textColor = RGBA(120, 120, 120, 1);
        rewindLabel.textColor = RGBA(120, 120, 120, 1);
        fastForwardLabel.textColor = RGBA(120, 120, 120, 1);
        recordLabel.textColor = RGBA(200, 200, 200, 1);
        
        [nc postNotificationName:@"didDisableRecordingTabBar" object:nil];
        [nc postNotificationName:@"didDisableTracksTabBar" object:nil];
        [nc postNotificationName:@"didDisableSongsTabBar" object:nil];
        [nc postNotificationName:@"didDisableSettingsTabBar" object:nil];
    }
}

//-----------------------------------------------------------------------------------
// RECORD TIME SLIDERS
-(void) didRecordMoveTimeSlider
{
	timeSlider.value += 1.0f;
	elapsedMin = (int)[timeSlider value] / 60;
	elapsedSec = (int)[timeSlider value] % 60;
	//elapsedTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d / %02d:%02d", elapsedMin, elapsedSec, (int)RECORDING_MINUTES, (int)RECORDING_SECONDS];
    elapsedTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", elapsedMin, elapsedSec];
	
	// Add track bar for recorded time period
	UIView *trackBar = [[UIView alloc] init];
	float start = trackBarStart + ((timeSlider.value - 1.0f) * trackUnitMultiplier);
	float end = trackBarStart + (timeSlider.value * trackUnitMultiplier);
	trackBar.frame = CGRectMake(start, 0.0f, end - start, track1Button.bounds.size.height);
	trackBar.backgroundColor = RGBA(255, 255, 0, 1);
	
	// Get track bar for current track
	UIView *currTrackBar = (UIView *)[self viewWithTag:TRACKBAR_TAG + trackNumber];
	[currTrackBar addSubview:trackBar];
	[trackBar release];
    
    // Play recorded tracks
    for(int i = 0; i < ([trackObjectArray count] - 1); i++)
    {
        TrackObject *aTrackObject = [trackObjectArray objectAtIndex:i];
        if(aTrackObject.isRecorded)
        {
            // Current track
            if(i == trackNumber)
            {
                [aTrackObject.player play];
            }
            else
            {
                int flag = [[aTrackObject.recordFlags substringWithRange:NSMakeRange((int)timeSlider.value, 1)] intValue];
                if(flag == NOTRECORDED_FLAG)
                {
                    [aTrackObject.player stop];
                    [aTrackObject.player setCurrentTime:0.0];
                }
                else if([aTrackObject.player isPlaying] == NO)
                {
                    // Get position of player based on the slider position
                    int posSlider = (int)timeSlider.value - 1.0f;
                    int posFlag;            // Flag at posSlider position
                    float posPlayer = 0.0;
                    
                    while(posSlider >= 0.0)
                    {
                        posFlag = [[aTrackObject.recordFlags substringWithRange:NSMakeRange((int)posSlider, 1)] intValue];
                        if(posFlag == NOTRECORDED_FLAG || posSlider == 0.0)
                        {
                            @try {
                                NSLog(@"trying...");                                  
                                //posPlayer = ((int)(timeSlider.value - posSlider) % (int)[aTrackObject.player duration]) - 1;  
                            }
                            @catch (NSException * e) {
                                NSLog(@"catching %@ reason %@", [e name], [e reason]);
                            }
                            @finally {
                                NSLog(@"finally");
                            }                          
                            break;
                        }
                        posSlider--;
                    }
                    [aTrackObject.player setCurrentTime:posPlayer];
                    [aTrackObject.player play];
                }
                else
                {
                    [aTrackObject.player play];
                }
            }
        }
    }
    
    timeSliderIndicator.value = timeSlider.value;	
	if((int)timeSlider.value == (int)timeSlider.maximumValue)
	{
		[self stopRecorder];
	}
}

//-----------------------------------------------------------------------------------
- (NSString *) dateString
{
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	formatter.dateFormat = @"ddMMMYY_hhmmssa";
	return [[formatter stringFromDate:[NSDate date]] stringByAppendingString:@".aif"];
}

- (void)alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if (buttonIndex == 0) {
		if (isMicRecording) {
			[micRecording stopRecording];
			[self stopRecorder];
		}
	}	
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	if(buttonIndex == 0)
	{
		int i;
		
		// Remove subviews in track bars
		for(i = 0; i < [trackObjectArray count]; i++)
		{
			UIView *trackBar = (UIView *)[self viewWithTag:TRACKBAR_TAG + i];
			for(UIView *subview in [trackBar subviews]) 
				[subview removeFromSuperview];
		}
		
		// Deselect current button
		UIButton *btn = (UIButton *)[self viewWithTag:TRACKBUTTON_TAG + trackNumber];
		btn.selected = NO;
		
		[nc postNotificationName:@"didSelectClearSong" object:nil];			
	}
}

//-----------------------------------------------------------------------------------
// AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)thisPlayer successfully:(BOOL)flag
{ 
	[thisPlayer release];
}

- (void)playerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
	NSLog(@"ERROR IN DECODE: %@\n", error);
}

//-----------------------------------------------------------------------------------

- (void)dealloc 
{
	[super dealloc];
	
	[clearLabel release];
	[saveLabel release];
	[songNameTextField release];
	
	[track1BarView release];
	[track2BarView release];
	[track3BarView release];
	[loopBarView release];
	
	[instrumentScrollView release];
	[elapsedTimeLabel release];
	[timeSlider release];
	[timeSliderIndicator release];
	
	[playLabel release];
	[rewindLabel release];
	[fastForwardLabel release];
	[recordLabel release];
	[playTimer invalidate];
	[rewTimer invalidate];
	[fwdTimer invalidate];
	[recTimer invalidate];
	
	[notRecordedAlert release];
    [noDrumBeatsAlert release];
	[micRecording release];
	[recordedMicArray release];
	[lvlMeter_in release];
}

@end
