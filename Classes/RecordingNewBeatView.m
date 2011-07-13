//
//  RecordNewBeatView.m
//  Solocaster
//
//  Created by Nikki Fernandez on 11/4/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import "RecordingNewBeatView.h"
#import <QuartzCore/QuartzCore.h>
#import "InstrumentObject.h"
#import "TrackObject.h"

#define SKIP_TIME 5.0
#define TEMPOTAPCOUNT_MAX 3
#define TEMPO_MIN 80
#define TEMPO_MAX 220

#define TIMESLIDER_MIN 0.0
#define TIMESLIDER_MAX 270.0

#define LOOPLENGTH_INCREMENT 4
#define LOOPLENGTH_TAG 300
#define DRUMPAD_TAG 400
#define DRUMPADLABEL_TAG 500
#define LAYOUT_GAP 1

// Color Macro
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@implementation RecordingNewBeatView

@synthesize tempo;
@synthesize loopLength;
@synthesize elapsedMin;
@synthesize elapsedSec;
@synthesize isRecordBeat;
@synthesize drumKitArray;
@synthesize selectedDrumPadArray;

- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) 
	{
		self.backgroundColor = RGBA(0, 0, 0, 1);
		
		// Initialize values
		isPlayMode = NO;
		isRecordMode = NO;
		buttonScanningRew = 0;
		buttonScanningFwd = 1;
		buttonStalling = 2;
		buttonIdle = 3;		
		buttonMode = buttonIdle;		
		nc = [NSNotificationCenter defaultCenter];
		
		//-------------------------------------------------------------------
		float ypos = 0.0f;
		
		// SETUP NAVIGATION BAR COMPONENTS
		cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cancelButton.frame = CGRectMake(0.0f, ypos, 79.25f, 50.0f);
		[cancelButton setImage:[UIImage imageNamed:@"cancel-btn.png"] forState:UIControlStateNormal];
		[cancelButton setImage:[UIImage imageNamed:@"cancel-btn-inactive.png"] forState:UIControlStateDisabled];
		[cancelButton setImage:[UIImage imageNamed:@"cancel-btn-pressed.png"] forState:UIControlStateHighlighted];
		[cancelButton addTarget:self action:@selector(tappedCancelButton:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:cancelButton];
		
		cancelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, cancelButton.bounds.size.height - 15.0f, cancelButton.bounds.size.width, 10.0f)];
		cancelLabel.backgroundColor = [UIColor clearColor];
		cancelLabel.font = [UIFont fontWithName:@"GrixelAcme7WideXtnd" size:8.0f];
		cancelLabel.textAlignment = UITextAlignmentCenter;
		cancelLabel.text = @"CANCEL";
		cancelLabel.textColor = RGBA(200, 200, 200, 1);
		[cancelButton addSubview:cancelLabel];
		
		doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
		doneButton.frame = CGRectMake(240.75f, ypos, 79.25f, 50.0f);
		[doneButton setImage:[UIImage imageNamed:@"done-btn.png"] forState:UIControlStateNormal];
		[doneButton setImage:[UIImage imageNamed:@"done-btn-pressed.png"] forState:UIControlStateHighlighted];
		[doneButton addTarget:self action:@selector(tappedDoneButton:) forControlEvents:UIControlEventTouchUpInside];		
		[self addSubview:doneButton];
		
		doneLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, doneButton.bounds.size.height - 15.0f, doneButton.bounds.size.width, 10.0f)];
		doneLabel.backgroundColor = [UIColor clearColor];
		doneLabel.font = [UIFont fontWithName:@"GrixelAcme7WideXtnd" size:8.0f];
		doneLabel.textAlignment = UITextAlignmentCenter;
		doneLabel.text = @"DONE";
		doneLabel.textColor = RGBA(200, 200, 200, 1);
		[doneButton addSubview:doneLabel];
		
		beatLabel = [[UILabel alloc] initWithFrame:CGRectMake(80.25f, ypos, 159.5f, 50.0f)];
		beatLabel.backgroundColor = RGBA(80, 80, 80, 1);
		beatLabel.font = [UIFont fontWithName:@"GrixelAcme7WideXtnd" size:15.0f];
		beatLabel.textAlignment = UITextAlignmentCenter;
		beatLabel.text = @"BEAT";
		beatLabel.textColor = RGBA(200, 200, 200, 1);
		[self addSubview:beatLabel];
		
		ypos += cancelButton.bounds.size.height + LAYOUT_GAP;
		//-------------------------------------------------------------------
		// SETUP DRUM KIT SCROLL
		UIImageView *instrumentView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, ypos + LAYOUT_GAP, 320.0f, 50.0f)];
		instrumentView.image = [UIImage imageNamed:@"nav-bar-shadow.png"];
		[self addSubview:instrumentView];
		
		instrumentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(30.0f, ypos + 5.0f, 260.0f, instrumentView.bounds.size.height - 10.0f)];
		instrumentScrollView.bounces = NO;
		instrumentScrollView.showsHorizontalScrollIndicator = NO;
		instrumentScrollView.pagingEnabled = YES;
		instrumentScrollView.delegate = self;
		[self addSubview:instrumentScrollView];

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
		// SETUP DRUM KIT PAD
		int i;
		float padXPos = 0.0f;
		float padYPos = 103.0f;
		float padWidth = 106.0f;
		float padHeight = 66.33f;
		for(i = 0; i < 8; i++)
		{
			// Tempo Button on the middle of the pad
			if(i == 4)
			{
				tempoButton = [UIButton buttonWithType:UIButtonTypeCustom];
				tempoButton.frame = CGRectMake(padXPos, padYPos, padWidth, padHeight);
				tempoButton.backgroundColor = RGBA(0, 0, 0, 1);
				[tempoButton addTarget:self action:@selector(tappedTempoButton:) forControlEvents:UIControlEventTouchUpInside];
				[self addSubview:tempoButton];
				
				tempoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 5.0f, tempoButton.bounds.size.width, 30.0f)];
				tempoLabel.font = [UIFont fontWithName:@"GrixelAcme7Wide" size:30.0f];
				tempoLabel.textColor = RGBA(213, 229, 34, 1);
				tempoLabel.backgroundColor = [UIColor clearColor];
				tempoLabel.textAlignment = UITextAlignmentCenter;
				[tempoButton addSubview:tempoLabel];

				UILabel *bpmLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 38.0f, tempoButton.bounds.size.width, 8.0f)];
				bpmLabel.font = [UIFont fontWithName:@"GrixelAcme7Wide" size:8.0f];
				bpmLabel.textColor = RGBA(120, 120, 120, 1);
				bpmLabel.backgroundColor = [UIColor clearColor];
				bpmLabel.text = @"BPM";
				bpmLabel.textAlignment = UITextAlignmentCenter;
				[tempoButton addSubview:bpmLabel];
				[bpmLabel release];
				
				UILabel *tapTempoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 55.0f, tempoButton.bounds.size.width, 8.0f)];
				tapTempoLabel.font = [UIFont fontWithName:@"GrixelAcme7Wide" size:8.0f];
				tapTempoLabel.textColor = RGBA(200, 200, 200, 1);
				tapTempoLabel.backgroundColor = [UIColor clearColor];
				tapTempoLabel.text = @"TAP TEMPO";
				tapTempoLabel.textAlignment = UITextAlignmentCenter;
				[tempoButton addSubview:tapTempoLabel];
				[tapTempoLabel release];
				
				padXPos += padWidth + LAYOUT_GAP;
			}
			
			UIButton *padBtn = [UIButton buttonWithType:UIButtonTypeCustom];
			padBtn.frame = CGRectMake(padXPos, padYPos, padWidth, padHeight);
			[padBtn setImage:[UIImage imageNamed:@"drumpad-btn.png"] forState:UIControlStateNormal];
			[padBtn setImage:[UIImage imageNamed:@"drumpad-btn-pressed.png"] forState:UIControlStateSelected];
			padBtn.tag = DRUMPAD_TAG + i;
			[padBtn addTarget:self action:@selector(tappedDrumPad:) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:padBtn];
			
			if(i == 2 || i== 4)
			{
				padXPos = 0.0f;
				padYPos += padHeight + LAYOUT_GAP;
			}
			else
			{
				padXPos += padWidth + LAYOUT_GAP;
			}
		}

		ypos = 305.0f;
		//-------------------------------------------------------------------
		// SETUP LOOP LENGTH BUTTONS
		
		UIView *loopLengthBgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, ypos, 320.0f, 45.0f)];
		loopLengthBgView.backgroundColor = RGBA(0, 0, 0, 1);
		
		UIButton *loopLengthButton = [UIButton buttonWithType:UIButtonTypeCustom];
		loopLengthButton.frame = CGRectMake(0.0f, ypos, 136.0f, 45.0f);
		loopLengthButton.backgroundColor = RGBA(80, 80, 80, 1);
		
		UILabel *loopLengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 0.0f, 131.0f, 45.0f)];
		loopLengthLabel.backgroundColor = [UIColor clearColor];
		loopLengthLabel.font = [UIFont fontWithName:@"GrixelAcme7WideXtnd" size:8.0f];
		loopLengthLabel.textAlignment = UITextAlignmentLeft;
		loopLengthLabel.text = @"LOOP LENGTH (BEATS)";
		loopLengthLabel.textColor = RGBA(200, 200, 200, 1);
		loopLengthLabel.lineBreakMode = UILineBreakModeWordWrap;
		loopLengthLabel.numberOfLines = 0;
		[loopLengthButton addSubview:loopLengthLabel];
		
		// LOOP LENGTH: 4
		loopLength4Button = [UIButton buttonWithType:UIButtonTypeCustom];
		loopLength4Button.frame = CGRectMake(137.0f, ypos, 45.0f, 45.0f);
		loopLength4Button.backgroundColor = [UIColor clearColor];
		[loopLength4Button setImage:[UIImage imageNamed:@"4-btn.png"] forState:UIControlStateNormal];
		[loopLength4Button setImage:[UIImage imageNamed:@"4-btn-selected.png"] forState:UIControlStateSelected];
		loopLength4Button.tag = LOOPLENGTH_TAG + 4;
		[loopLength4Button addTarget:self action:@selector(tappedLoopLengthButton:) forControlEvents:UIControlEventTouchUpInside];		
        loopLength4Button.selected = NO;

		loopLength8Button = [UIButton buttonWithType:UIButtonTypeCustom];
		loopLength8Button.frame = CGRectMake(183.0f, ypos, 45.0f, 45.0f);
		loopLength8Button.backgroundColor = [UIColor clearColor];
		[loopLength8Button setImage:[UIImage imageNamed:@"8-btn.png"] forState:UIControlStateNormal];
		[loopLength8Button setImage:[UIImage imageNamed:@"8-btn-selected.png"] forState:UIControlStateSelected];
		loopLength8Button.tag = LOOPLENGTH_TAG + 8;
		[loopLength8Button addTarget:self action:@selector(tappedLoopLengthButton:) forControlEvents:UIControlEventTouchUpInside];		
        loopLength8Button.selected = NO;
		
		loopLength12Button = [UIButton buttonWithType:UIButtonTypeCustom];
		loopLength12Button.frame = CGRectMake(229.0f, ypos, 45.0f, 45.0f);
		loopLength12Button.backgroundColor = [UIColor clearColor];
		[loopLength12Button setImage:[UIImage imageNamed:@"12-btn.png"] forState:UIControlStateNormal];
		[loopLength12Button setImage:[UIImage imageNamed:@"12-btn-selected.png"] forState:UIControlStateSelected];
		loopLength12Button.tag = LOOPLENGTH_TAG + 12;
		[loopLength12Button addTarget:self action:@selector(tappedLoopLengthButton:) forControlEvents:UIControlEventTouchUpInside];		
        loopLength12Button.selected = NO;
		
		loopLength16Button = [UIButton buttonWithType:UIButtonTypeCustom];
		loopLength16Button.frame = CGRectMake(275.0f, ypos, 45.0f, 45.0f);
		loopLength16Button.backgroundColor = [UIColor clearColor];
		[loopLength16Button setImage:[UIImage imageNamed:@"16-btn.png"] forState:UIControlStateNormal];
		[loopLength16Button setImage:[UIImage imageNamed:@"16-btn-selected.png"] forState:UIControlStateSelected];
		loopLength16Button.tag = LOOPLENGTH_TAG + 16;
		[loopLength16Button addTarget:self action:@selector(tappedLoopLengthButton:) forControlEvents:UIControlEventTouchUpInside];		
        loopLength16Button.selected = NO;
		
		ypos = 340.0f;
		//-------------------------------------------------------------------
		// SETUP TIME SLIDER
		UIImageView *timeSliderBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, ypos, 320.0f, 40.0f)];
		timeSliderBgView.image = [UIImage imageNamed:@"loop-pregression-bar-bg.png"];
		
		UIImageView *timeSliderTickersView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, ypos + 11.0f, 320.0f, 9.0f)];
		timeSliderTickersView.image = [UIImage imageNamed:@"loop-progression-tickers.png"];
		timeSliderTickersView.backgroundColor = [UIColor clearColor];
		
		// Clear Slider Thumb
		UIView *clearSliderThumbView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 5.0f, 10.0f)];
		clearSliderThumbView.backgroundColor = [UIColor clearColor];
		UIGraphicsBeginImageContext(clearSliderThumbView.bounds.size);
		[clearSliderThumbView.layer renderInContext:UIGraphicsGetCurrentContext()];
		UIImage *clearSliderThumbImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		UIImageView *sliderMinView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 10.0f)];
		sliderMinView.image = [UIImage imageNamed:@"loop-progression-bar.png"];
		UIGraphicsBeginImageContext(sliderMinView.bounds.size);
		[sliderMinView.layer renderInContext:UIGraphicsGetCurrentContext()];
		UIImage *sliderMinImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		UIView *sliderMaxView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 10.0f)];
		sliderMaxView.backgroundColor = [UIColor clearColor];
		UIGraphicsBeginImageContext(sliderMaxView.bounds.size);
		[sliderMaxView.layer renderInContext:UIGraphicsGetCurrentContext()];
		UIImage *sliderMaxImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
				
		timeSlider = [[UISlider alloc] initWithFrame:CGRectMake(0.0f, ypos + 5.0f, 320.0f, 5.0f)];
		timeSlider.backgroundColor = [UIColor clearColor];        
		[timeSlider setThumbImage: clearSliderThumbImage forState:UIControlStateNormal];
		[timeSlider setMinimumTrackImage:sliderMinImage forState:UIControlStateNormal];
		[timeSlider setMaximumTrackImage:sliderMaxImage forState:UIControlStateNormal];
		timeSlider.minimumValue = TIMESLIDER_MIN;
		timeSlider.maximumValue = TIMESLIDER_MAX;
		timeSlider.continuous = YES;
		[timeSlider addTarget:self action:@selector(didMoveTimeSlider) forControlEvents:UIControlEventValueChanged];
		
		ypos = 360.0f;
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
		//rewindLabel.textColor = RGBA(200, 200, 200, 1);
        rewindLabel.textColor = RGBA(120, 120, 120, 1);
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
		//fastForwardLabel.textColor = RGBA(200, 200, 200, 1);
        fastForwardLabel.textColor = RGBA(120, 120, 120, 1);
		[fastForwardButton addSubview:fastForwardLabel];
		
		recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
		recordButton.frame = CGRectMake(240.75f, ypos, 79.25f, 100.0f);
		recordButton.backgroundColor = RGBA(40, 40, 40, 1);
		[recordButton setImage:[UIImage imageNamed:@"rec-btn.png"] forState:UIControlStateNormal];
		[recordButton setImage:[UIImage imageNamed:@"rec-btn-inactive.png"] forState:UIControlStateDisabled];
		[recordButton setImage:[UIImage imageNamed:@"rec-btn-selected.png"] forState:UIControlStateSelected];
		[recordButton addTarget:self action:@selector(tappedRecordButton:) forControlEvents:UIControlEventTouchUpInside];
        recordButton.enabled = YES;

		recordLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, recordButton.bounds.size.height - 30.0f, recordButton.bounds.size.width, 10.0f)];
		recordLabel.backgroundColor = [UIColor clearColor];
		recordLabel.font = [UIFont fontWithName:@"GrixelAcme7WideXtnd" size:8.0f];
		recordLabel.textAlignment = UITextAlignmentCenter;
		recordLabel.text = @"REC";
		//recordLabel.textColor = RGBA(200, 200, 200, 1);
        recordLabel.textColor = RGBA(120, 120, 120, 1);
		[recordButton addSubview:recordLabel];
		
		[self addSubview:rewindButton];
		[self addSubview:playButton];
		[self addSubview:fastForwardButton];
		[self addSubview:recordButton];
				
		[self addSubview:timeSliderBgView];
		[self addSubview:timeSlider];
		[self addSubview:timeSliderTickersView];
		
		[self addSubview:loopLengthBgView];
		[self addSubview:loopLengthButton];
		[self addSubview:loopLength4Button];
		[self addSubview:loopLength8Button];
		[self addSubview:loopLength12Button];
		[self addSubview:loopLength16Button];
		
		[loopLengthBgView release];	
		
		selectedDrumPadArray = [[NSMutableArray alloc] initWithObjects:nil];
    }
    return self;
}

-(void) fillInViewValues
{
	int i;
	
	// Instrument scroll view
	instrumentScrollView.contentSize = CGSizeMake(instrumentScrollView.bounds.size.width, 30.0f);

	UIButton *istrumentButton = [UIButton buttonWithType:UIButtonTypeCustom];
	istrumentButton.frame = CGRectMake(0.0f, 0.0f, instrumentScrollView.bounds.size.width, 40.0f);
	[istrumentButton setTitle:@"DRUMS" forState:UIControlStateNormal];
	istrumentButton.titleLabel.font = [UIFont fontWithName:@"GrixelAcme7Wide" size:24.0f];
	istrumentButton.backgroundColor = [UIColor clearColor];
	[istrumentButton setTitleColor:RGBA(200, 200, 200, 1) forState:UIControlStateNormal];
	[instrumentScrollView addSubview:istrumentButton];
    
	// Add Drum Pad Labels
	float padXPos = 0.0f;
	float padYPos = 103.0f;
	float padWidth = 106.0f;
	float padHeight = 66.33f;
    InstrumentObject *anInstrumentObject;
	for(i = 0; i < 8; i++)
	{
		anInstrumentObject = [drumKitArray objectAtIndex:i];
		if(i == 4)	padXPos += padWidth + LAYOUT_GAP;

		UILabel *padLabel = [[UILabel alloc] initWithFrame:CGRectMake(padXPos, padYPos + 50.0f, 106.0f, 10.0f)];
		padLabel.backgroundColor = [UIColor clearColor];
		padLabel.font = [UIFont fontWithName:@"GrixelAcme7WideXtnd" size:8.0f];
		padLabel.textAlignment = UITextAlignmentLeft;
		padLabel.text = [NSString stringWithFormat:@" %@", anInstrumentObject.name];
		padLabel.textColor = RGBA(200, 200, 200, 1);
        padLabel.tag = DRUMPADLABEL_TAG + i;
		[self addSubview:padLabel];
		[padLabel release];
		
		if(i == 2 || i == 4)
		{
			padXPos = 0.0f;
			padYPos += padHeight + LAYOUT_GAP;
		}
		else
		{
			padXPos += padWidth + LAYOUT_GAP;
		}
	}
    
	// Select loop length button
    loopLength4Button.selected = NO;
    loopLength8Button.selected = NO;
    loopLength12Button.selected = NO;
    loopLength16Button.selected = NO;
	UIButton *loopLengthBtn = (UIButton*)[self viewWithTag:(int)LOOPLENGTH_TAG + loopLength];
	loopLengthBtn.selected = YES;
	
	// Tempo
	tempoTapCount = 0;
	tempoTapTimeArray = [[NSMutableArray alloc] initWithObjects:nil];	
	tempoLabel.text = [NSString stringWithFormat:@"%03d", tempo];
	tempoTimeInterval = (float) 60.0f / (float) tempo;
	
	// Time Slider
	timeSlider.value = 0;
	
	// Disable rewind and forward buttons
    rewindButton.enabled = NO;
    fastForwardButton.enabled = NO;
}

-(void) tappedCancelButton:(id) sender
{
    // Reset selected drum Pad array
    for(int i = 0; i < [selectedDrumPadArray count]; i++)
        [selectedDrumPadArray replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:-1]];
	[nc postNotificationName:@"didCancelRecordNewBeat" object:nil];
}

-(void) tappedDoneButton:(id) sender
{
    // Check if a drum beat has been recorded
    BOOL foundRecorded = NO;
    for(int i = 0; i < [selectedDrumPadArray count]; i++)
    {
        if([[selectedDrumPadArray objectAtIndex:i] intValue] != -1)
        {
            foundRecorded = YES;
            break;
        }
    }
    if(foundRecorded)
        [nc postNotificationName:@"didSaveRecordNewBeat" object:selectedDrumPadArray];
}

-(void) tappedLoopLengthButton:(id) sender
{
	UIButton *btn = (UIButton *)sender;
	int currLoopLength = btn.tag - LOOPLENGTH_TAG;
	
	// Deselect previous loop length
	UIButton *prevBtn = (UIButton *)[self viewWithTag:LOOPLENGTH_TAG + loopLength];
	prevBtn.selected = NO;
	
	// Update for current loop length
	btn.selected = YES;
	loopLength = currLoopLength;
	
	// Send notification
	[nc postNotificationName:@"didToggleLoopLengthSettings" object:[NSNumber numberWithInt:loopLength]];
}

-(void) tappedTempoButton:(id) sender
{
	if(tempoTapCount < TEMPOTAPCOUNT_MAX)
	{
		[tempoTapTimeArray addObject:[NSDate date]];
		tempoTapCount++;
	}
	
	if(tempoTapCount == TEMPOTAPCOUNT_MAX)
	{
		float diffAverage = 0.0f;
		
		// Tempo is computed as the average time between four taps
		// Get time interval (in seconds) between the taps
		for(int i = 1; i < [tempoTapTimeArray count]; i++)
		{
			NSDate *firstDate = [tempoTapTimeArray objectAtIndex:(i-1)];
			NSDate *secondDate = [tempoTapTimeArray objectAtIndex:i];
			
			NSTimeInterval timeDiff = [secondDate timeIntervalSinceDate:firstDate];
			diffAverage = diffAverage + timeDiff;
		}
		diffAverage = (float)diffAverage / (float)(TEMPOTAPCOUNT_MAX - 1);
		tempo = ((float)1.0f / (float)diffAverage) * 60;
		
		if(tempo < TEMPO_MIN)
			tempo = TEMPO_MIN;
		else if(tempo > TEMPO_MAX)
			tempo = TEMPO_MAX;
		
		tempoLabel.text = [NSString stringWithFormat:@"%03d", tempo];
		[nc postNotificationName:@"didChangeTempo" object:[NSNumber numberWithInt:tempo]];
		
		// Reset tempo tap variables
		tempoTapCount = 0;
		[tempoTapTimeArray removeAllObjects];
		tempoTimeInterval = (float) 60.0f / (float) tempo;
	}	
}

-(void) tappedDrumPad:(id) sender
{
    UIButton *btn = (UIButton *)sender;
    int currDrumPad = btn.tag;
    drumPad = currDrumPad - DRUMPAD_TAG;
    
    if(isRecordMode)
    {
        [selectedDrumPadArray replaceObjectAtIndex:beatCounter withObject:[NSNumber numberWithInt:drumPad]];
        beatCounter++;
        
        // Move slider
        timeSlider.value += tempoTimeInterval;
        elapsedMin = (int)[timeSlider value] / 60;
        elapsedSec = (int)[timeSlider value] % 60;
        
        if(beatCounter == loopLength)
            [self stopRecorder];
    }
    
    // Play sound
    InstrumentObject *anInstrumentObject = [drumKitArray objectAtIndex:drumPad];
    AVAudioPlayer *drumPlayer = [[AVAudioPlayer alloc] 
                                 initWithContentsOfURL:[NSURL 
                                                        fileURLWithPath:[[NSBundle mainBundle] 
                                                                         pathForResource:[NSString stringWithFormat:@"%@", anInstrumentObject.fileName] 
                                                                         ofType:[NSString stringWithFormat:@"%@", anInstrumentObject.extensionType]]]
                                 error:nil];
    [drumPlayer setDelegate:self];
    [drumPlayer play];
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
	scanTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(didPlayMoveTimeSlider) userInfo:nil repeats:YES];
}

-(void) stopRewindScan
{	
	[scanTimer invalidate];
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
	scanTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(didPlayMoveTimeSlider) userInfo:nil repeats:YES];
}

-(void) stopForwardScan
{	
	[scanTimer invalidate];
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
        bool foundRecorded = NO;
        // Check if there has been a recording
        for(int i = 0; i < [selectedDrumPadArray count]; i++)
        {
            if([[selectedDrumPadArray objectAtIndex:i] intValue] != -1)
            {
                foundRecorded = YES;
                break;
            }
        }
        
        if(foundRecorded)
            [self startPlayer];
	}
}

-(void) startPlayer
{
	beatCounter = 0;
    
	// Set time slider
	timeSlider.value = 0.0;
	timeSlider.maximumValue = loopLength * tempoTimeInterval;
        
	playTimer = [NSTimer scheduledTimerWithTimeInterval:tempoTimeInterval target:self selector:@selector(didPlayMoveTimeSlider) userInfo:nil repeats:YES];	
	
	isPlayMode = YES;
	hasReachedEnd = NO;
    [self updatePlayControlState:YES];
}

-(void) pausePlayer
{
    if(playTimer != nil)
        [playTimer invalidate];
	
	isPlayMode = NO;
    [self updatePlayControlState:NO];	
}

-(void) stopPlayer
{
	if(buttonMode == buttonScanningFwd)		
		[self stopForwardScan];
	else if(buttonMode == buttonScanningRew)
		[self stopRewindScan];
	buttonMode = buttonIdle;
    
    if(playTimer != nil)
        [playTimer invalidate];
    
	timeSlider.value = 0;
	isPlayMode = NO;
    [self updatePlayControlState:NO];	
	[timeSlider sendActionsForControlEvents:UIControlEventValueChanged];
}

-(void) updatePlayControlState:(BOOL) isPlaying
{
    cancelButton.enabled = !isPlaying;
	doneButton.enabled = !isPlaying;
	instrumentScrollView.scrollEnabled = !isPlaying;
	playButton.selected = isPlaying;
	recordButton.enabled = !isPlaying;
	tempoButton.enabled = !isPlaying;
    
    if(isPlaying)
    {
        cancelLabel.textColor = RGBA(120, 120, 120, 1);
        doneLabel.textColor = RGBA(120, 120, 120, 1);
        playLabel.text = @"PAUSE";
        playLabel.textColor = RGBA(200, 200, 200, 1);
        recordLabel.textColor = RGBA(120, 120, 120, 1);
        
        if(loopLength4Button.selected == NO)	loopLength4Button.enabled = NO;
        if(loopLength8Button.selected == NO)	loopLength8Button.enabled = NO;
        if(loopLength12Button.selected == NO)	loopLength12Button.enabled = NO;
        if(loopLength16Button.selected == NO)	loopLength16Button.enabled = NO;
    }
    else
    {
        cancelLabel.textColor = RGBA(200, 200, 200, 1);
        doneLabel.textColor = RGBA(200, 200, 200, 1);
        playLabel.text = @"PLAY";
        playLabel.textColor = RGBA(200, 200, 200, 1);
        recordLabel.textColor = RGBA(200, 200, 200, 1);

        loopLength4Button.enabled = YES;
        loopLength8Button.enabled = YES;
        loopLength12Button.enabled = YES;
        loopLength16Button.enabled = YES;
    }
}

//-----------------------------------------------------------------------------------
// PLAY TIME SLIDERS
-(void) didPlayMoveTimeSlider
{
    if(beatCounter == loopLength)
    {
        beatCounter = 0;
        timeSlider.value = 0.0f;
    }
    else
    {
        if(buttonMode == buttonScanningFwd)
            timeSlider.value += SKIP_TIME;	
        else if(buttonMode == buttonScanningRew)
            timeSlider.value -= SKIP_TIME;	
        else 
            timeSlider.value += tempoTimeInterval;
        
        if(hasReachedEnd == YES)
        {
            timeSlider.value = tempoTimeInterval;
            hasReachedEnd = NO;
        }
        
        if(timeSlider.value == timeSlider.maximumValue)
            hasReachedEnd = YES;
        
        [timeSlider sendActionsForControlEvents:UIControlEventValueChanged];
        
        // Play drums
        int currentDrum = [[selectedDrumPadArray objectAtIndex:beatCounter] intValue];
        if(currentDrum != -1)
        {
            InstrumentObject *anInstrumentObject = [drumKitArray objectAtIndex:currentDrum];
            AVAudioPlayer *drumPlayer = [[AVAudioPlayer alloc] 
                                         initWithContentsOfURL:[NSURL 
                                                                fileURLWithPath:[[NSBundle mainBundle] 
                                                                                 pathForResource:[NSString stringWithFormat:@"%@", anInstrumentObject.fileName] 
                                                                                 ofType:[NSString stringWithFormat:@"%@", anInstrumentObject.extensionType]]]
                                         error:nil];
            [drumPlayer setDelegate:self];
            [drumPlayer play];
        }
        beatCounter++;
    }
}

-(void) didMoveTimeSlider
{
	elapsedMin = (int)[timeSlider value] / 60;
	elapsedSec = (int)[timeSlider value] % 60;
}

-(void) sendTimeSliderNotification
{
	NSDictionary *timeDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithInt:elapsedMin], @"elapsedMin",
							  [NSNumber numberWithInt:elapsedSec], @"elapsedSec",
							  nil];
	[nc postNotificationName:@"didMoveNewBeatTimeSlider" object:timeDict];
}

//-----------------------------------------------------------------------------------
// RECORD IMPLEMENTATION
-(void) tappedRecordButton:(id) sender
{
	if(isRecordMode == YES)
	{
		isRecordMode = NO;
		[self stopRecorder];
	}
	else 
	{
		isRecordMode = YES;
		[self startRecorder];
	}
}

-(void) startRecorder
{
	// Set time slider
	timeSlider.value = 0.0;
	timeSlider.maximumValue = loopLength * tempoTimeInterval;
    
    // Set drum pad array
    beatCounter = 0;
    metronomeCounter = 0;

    [selectedDrumPadArray removeAllObjects];
    for(int i = 0; i < 16; i++)     // 16 is the maximum loop length
        [selectedDrumPadArray addObject:[NSNumber numberWithInt:-1]];

    if(isRecordBeat)
        metronomeTimer = [NSTimer scheduledTimerWithTimeInterval:tempoTimeInterval target:self selector:@selector(didPlayMetronome) userInfo:nil repeats:YES];
	
    [self updateRecordControlState:YES];
}

-(void) stopRecorder
{
    if(metronomeTimer != nil)
        [metronomeTimer invalidate];
    
    isRecordMode = NO;
    [self updateRecordControlState:NO];
}

-(void) updateRecordControlState:(BOOL) isRecording
{
    cancelButton.enabled = !isRecording;
	doneButton.enabled = !isRecording;
	instrumentScrollView.scrollEnabled = !isRecording;
	playButton.enabled = !isRecording;
	//rewindButton.enabled = !isRecording;
	//fastForwardButton.enabled = !isRecording;
	recordButton.selected = isRecording;    
	tempoButton.enabled = !isRecording;
	timeSlider.enabled = !isRecording;
    
    if(isRecording)
    {
        cancelLabel.textColor = RGBA(120, 120, 120, 1);
        doneLabel.textColor = RGBA(120, 120, 120, 1);
        playLabel.textColor = RGBA(120, 120, 120, 1);
        //rewindLabel.textColor = RGBA(120, 120, 120, 1);
        //fastForwardLabel.textColor = RGBA(120, 120, 120, 1);
        recordLabel.textColor = RGBA(200, 200, 200, 1);
        
        if(loopLength4Button.selected == NO)	loopLength4Button.enabled = NO;
        if(loopLength8Button.selected == NO)	loopLength8Button.enabled = NO;
        if(loopLength12Button.selected == NO)	loopLength12Button.enabled = NO;
        if(loopLength16Button.selected == NO)	loopLength16Button.enabled = NO;
    }
    else
    {
        cancelLabel.textColor = RGBA(200, 200, 200, 1);
        doneLabel.textColor = RGBA(200, 200, 200, 1);
        playLabel.textColor = RGBA(200, 200, 200, 1);
        //rewindLabel.textColor = RGBA(200, 200, 200, 1);
        //fastForwardLabel.textColor = RGBA(200, 200, 200, 1);
        recordLabel.textColor = RGBA(200, 200, 200, 1);
        
        loopLength4Button.enabled = YES;
        loopLength8Button.enabled = YES;
        loopLength12Button.enabled = YES;
        loopLength16Button.enabled = YES;
    }
}

//-----------------------------------------------------------------------------------

// Play Metronome
-(void) didPlayMetronome
{
    if(metronomeCounter == loopLength - 1)
    {
        AVAudioPlayer *metronomePlayer = [[AVAudioPlayer alloc] 
                                          initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"tock" ofType:@"caf"]]
                                          error:nil];
        [metronomePlayer setDelegate:self];
        [metronomePlayer play];
        metronomeCounter = 0;
    }
    else
    {
        AVAudioPlayer *metronomePlayer = [[AVAudioPlayer alloc] 
                                          initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"tick" ofType:@"caf"]]
                                          error:nil];
        [metronomePlayer setDelegate:self];
        [metronomePlayer play];
        ++metronomeCounter;
    }
}

//-----------------------------------------------------------------------------------
-  (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	CGRect visibleRect;
	visibleRect.origin = instrumentScrollView.contentOffset;
	visibleRect.size = instrumentScrollView.bounds.size;
	instrument = visibleRect.origin.x / visibleRect.size.width;
}

//-----------------------------------------------------------------------------------
// Release player when done playing
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	[player release];
}

- (void)dealloc 
{
    [super dealloc];
	
	[tempoTapTimeArray release];
	
	[cancelLabel release];
	[doneLabel release];
	[beatLabel release];
	[instrumentScrollView release];
	[tempoLabel release];
	[timeSlider release];
	
	[rewindLabel release];
	[playLabel release];
	[fastForwardLabel release];
	[recordLabel release];
	
	[playTimer invalidate];
	[metronomeTimer invalidate];
	[scanTimer invalidate];
}

@end
