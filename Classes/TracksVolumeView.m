//
//  TracksVolumeView.m
//  Solocaster
//
//  Created by Nikki Fernandez on 11/4/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import "TracksVolumeView.h"
#import <QuartzCore/QuartzCore.h>
#import "TriangleView.h"
#import "TrackObject.h"
#import "InstrumentObject.h"
#import "TempoSliderThumbView.h"

#define SKIP_TIME 5.0
#define VOLUME_MIN 0.0
#define VOLUME_MAX 1.0
#define TEMPO_MIN 80
#define TEMPO_MAX 220
#define TIMESLIDER_MIN 0.0
#define TIMESLIDER_MAX 270.0

#define RECORDING_MINUTES 4
#define RECORDING_SECONDS 30

#define NOTRECORDED_FLAG 0
#define RECORDED_FLAG 1

#define LAYOUT_GAP 1			// Gap between controls in layout: 2 pixels = 1pt

#define TRACKBUTTON_TAG 300
#define SHARESONGAS_TAG 400
#define SAVESONGAS_TAG 401

#define DRUM_TRACK 3

// Color Macro
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@implementation TracksVolumeView

@synthesize songID;
@synthesize elapsedMin;
@synthesize elapsedSec;
@synthesize tempo;
@synthesize loopLength;
@synthesize trackObjectArray;
@synthesize instrumentArray;
@synthesize drumKitArray;

- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) 
	{
		self.backgroundColor = [UIColor blackColor];
		
		// Initialize values
		isPlayMode = NO;
		buttonScanningRew = 0;
		buttonScanningFwd = 1;
		buttonStalling = 2;
		buttonIdle = 3;		
		buttonMode = buttonIdle;	
		hasReachedEnd = NO;
		prevRewindTapTime = nil;
		nc = [NSNotificationCenter defaultCenter];
		
		float ypos = 0.0f;
		
		// SETUP NAVIGATION BAR COMPONENTS
		shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
		shareButton.frame = CGRectMake(0.0f, ypos, 79.25, 50.0f);
		[shareButton setImage:[UIImage imageNamed:@"share-btn.png"] forState:UIControlStateNormal];
		[shareButton setImage:[UIImage imageNamed:@"share-btn-inactive.png"] forState:UIControlStateDisabled];
		[shareButton setImage:[UIImage imageNamed:@"share-btn-pressed.png"] forState:UIControlStateHighlighted];
		[shareButton addTarget:self action:@selector(tappedShareSongButton:) forControlEvents:UIControlEventTouchUpInside];

		shareLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, shareButton.bounds.size.height - 15.0f, shareButton.bounds.size.width, 10.0f)];
		shareLabel.backgroundColor = [UIColor clearColor];
		shareLabel.font = [UIFont fontWithName:@"GrixelAcme7WideXtnd" size:8.0f];
		shareLabel.textAlignment = UITextAlignmentCenter;
		shareLabel.text = @"SHARE";
		shareLabel.textColor = RGBA(200, 200, 200, 1);
		[shareButton addSubview:shareLabel];
		
		volumeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		volumeButton.frame = CGRectMake(80.25f, ypos, 79.25, 50.0f);
		[volumeButton setImage:[UIImage imageNamed:@"volume-btn.png"] forState:UIControlStateNormal];
		[volumeButton setImage:[UIImage imageNamed:@"volume-btn-selected.png"] forState:UIControlStateSelected];
		volumeButton.selected = YES;
		
		volumeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, volumeButton.bounds.size.height - 15.0f, volumeButton.bounds.size.width, 10.0f)];
		volumeLabel.backgroundColor = [UIColor clearColor];
		volumeLabel.font = [UIFont fontWithName:@"GrixelAcme7WideXtnd" size:8.0f];
		volumeLabel.textAlignment = UITextAlignmentCenter;
		volumeLabel.text = @"VOLUME";
		volumeLabel.textColor = RGBA(255, 255, 0, 1);
		[volumeButton addSubview:volumeLabel];
		
		pitchButton = [UIButton buttonWithType:UIButtonTypeCustom];
		pitchButton.frame = CGRectMake(160.5f, ypos, 79.25, 50.0f);
		[pitchButton setImage:[UIImage imageNamed:@"pitch-btn.png"] forState:UIControlStateNormal];
		[pitchButton setImage:[UIImage imageNamed:@"pitch-btn-selected.png"] forState:UIControlStateSelected];
		[pitchButton addTarget:self action:@selector(tappedPitchButton:) forControlEvents:UIControlEventTouchUpInside];
		
		pitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, pitchButton.bounds.size.height - 15.0f, pitchButton.bounds.size.width, 10.0f)];
		pitchLabel.backgroundColor = [UIColor clearColor];
		pitchLabel.font = [UIFont fontWithName:@"GrixelAcme7WideXtnd" size:8.0f];
		pitchLabel.textAlignment = UITextAlignmentCenter;
		pitchLabel.text = @"PITCH";
		pitchLabel.textColor = RGBA(200, 200, 200, 1);
		[pitchButton addSubview:pitchLabel];
		
		saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
		saveButton.frame = CGRectMake(240.75f, ypos, 79.25, 50.0f);
		[saveButton setImage:[UIImage imageNamed:@"save-btn.png"] forState:UIControlStateNormal];
		[saveButton setImage:[UIImage imageNamed:@"save-btn-inactive.png"] forState:UIControlStateDisabled];
		[saveButton setImage:[UIImage imageNamed:@"save-btn-pressed.png"] forState:UIControlStateHighlighted];
		[saveButton addTarget:self action:@selector(tappedSaveSongButton:) forControlEvents:UIControlEventTouchUpInside];

		saveLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, saveButton.bounds.size.height - 15.0f, saveButton.bounds.size.width, 10.0f)];
		saveLabel.backgroundColor = [UIColor clearColor];
		saveLabel.font = [UIFont fontWithName:@"GrixelAcme7WideXtnd" size:8.0f];
		saveLabel.textAlignment = UITextAlignmentCenter;
		saveLabel.text = @"SAVE";
		saveLabel.textColor = RGBA(200, 200, 200, 1);
		[saveButton addSubview:saveLabel];
		
		ypos += shareButton.bounds.size.height;
		
		// SETUP CONTROLLER BACKGROUND
		UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, ypos, 320.0f, 280.5f)];
		bgView.image = [UIImage imageNamed:@"controller-bg.png"];
		
		//-------------------------------------------------------------------
		ypos += 21.0f;
		
		// Add slider backgrounds
		UIImageView *track1BgView = [[UIImageView alloc] initWithFrame:CGRectMake(11.53f, ypos, 55.5f, 156.0f)];
		track1BgView.image = [UIImage imageNamed:@"volume-control-bg.png"];
		UIImageView *track2BgView = [[UIImageView alloc] initWithFrame:CGRectMake(91.53f, ypos, 57.0f, 156.0f)];
		track2BgView.image = [UIImage imageNamed:@"volume-control-bg.png"];
		UIImageView *track3BgView = [[UIImageView alloc] initWithFrame:CGRectMake(171.53f, ypos, 57.0f, 156.0f)];
		track3BgView.image = [UIImage imageNamed:@"volume-control-bg.png"];
		UIImageView *track4BgView = [[UIImageView alloc] initWithFrame:CGRectMake(251.53f, ypos, 57.0f, 156.0f)];
		track4BgView.image = [UIImage imageNamed:@"volume-control-bg.png"];
		
		CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI * -0.5);

		// SETUP MAXIMUM SLIDER IMAGE
		UIView *maxSliderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 156.0f, 57.0f)];
		maxSliderView.backgroundColor = [UIColor clearColor];
		UIGraphicsBeginImageContext(maxSliderView.bounds.size);
		[maxSliderView.layer renderInContext:UIGraphicsGetCurrentContext()];
		UIImage *maxSliderImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		[maxSliderView release];
		
		// SETUP MINIMUM SLIDER IMAGE
		UIView *minSliderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 156.0f, 60.0f)];
		minSliderView.backgroundColor = RGBA(117, 128, 0, 1);
		UIGraphicsBeginImageContext(minSliderView.bounds.size);
		[minSliderView.layer renderInContext:UIGraphicsGetCurrentContext()];
		UIImage *minSliderImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		[minSliderView release];
		
		// SETUP SLIDER THUMB - RECORDED
		UIView *sliderThumbView = [[UIView alloc] initWithFrame:CGRectMake(7.0f, 100.0f, 1.8f, 65.0f)];
		sliderThumbView.backgroundColor = RGBA(255, 255, 0, 1);
		sliderThumbView.layer.cornerRadius = 1.0f;
		UIGraphicsBeginImageContext(sliderThumbView.bounds.size);
		[sliderThumbView.layer renderInContext:UIGraphicsGetCurrentContext()];
		UIImage *sliderThumbImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		[sliderThumbView release];
		
		// SETUP SLIDER THUMB - NOT RECORDED
		UIView *sliderThumbNotRecView = [[UIView alloc] initWithFrame:CGRectMake(7.0f, 100.0f, 1.8f, 65.0f)];
		sliderThumbNotRecView.backgroundColor = [UIColor clearColor];
		sliderThumbNotRecView.layer.cornerRadius = 1.0f;
		UIGraphicsBeginImageContext(sliderThumbNotRecView.bounds.size);
		[sliderThumbNotRecView.layer renderInContext:UIGraphicsGetCurrentContext()];
		UIImage *sliderThumbNotRecImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		[sliderThumbNotRecView release];
		
		float trackSliderYPos = 120.0f;
		float trackNumberYPos = 53.0f;
		float trackNameYPos = 228.0f;
		
		// TRACK 1 SLIDER
		track1VolumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(-40.0f, trackSliderYPos, 160.0f, 57.0f)];
		track1VolumeSlider.backgroundColor = [UIColor clearColor];        
		[track1VolumeSlider setThumbImage: sliderThumbImage forState:UIControlStateNormal];
		[track1VolumeSlider setThumbImage: sliderThumbNotRecImage forState:UIControlStateDisabled];
		[track1VolumeSlider setMinimumTrackImage:minSliderImage forState:UIControlStateNormal];
		[track1VolumeSlider setMaximumTrackImage:maxSliderImage forState:UIControlStateNormal];
		track1VolumeSlider.minimumValue = VOLUME_MIN;
		track1VolumeSlider.maximumValue = VOLUME_MAX;
		track1VolumeSlider.continuous = YES;
		[track1VolumeSlider addTarget:self action:@selector(didMoveTrack1VolumeSlider) forControlEvents:UIControlEventValueChanged];
		track1VolumeSlider.transform = trans;
		
		track1NumberButton = [UIButton buttonWithType:UIButtonTypeCustom];
		track1NumberButton.frame = CGRectMake(0.0f, trackNumberYPos, 79.25f, 20.0f);
		track1NumberButton.titleLabel.font = [UIFont fontWithName:@"GrixelAcme7WideXtnd" size:8.0f];
		track1NumberButton.backgroundColor = [UIColor clearColor];
		track1NumberButton.titleLabel.textAlignment = UITextAlignmentCenter;
		[track1NumberButton setTitle:@"1" forState:UIControlStateNormal];
		[track1NumberButton setTitleColor:RGBA(120, 120, 120, 1) forState: UIControlStateNormal];

		track1NameButton = [UIButton buttonWithType:UIButtonTypeCustom];
		track1NameButton.frame = CGRectMake(5.0f, trackNameYPos, 69.25f, 20.0f);
		track1NameButton.titleLabel.font = [UIFont fontWithName:@"GrixelAcme7WideXtnd" size:8.0f];
		track1NameButton.titleLabel.textAlignment = UITextAlignmentCenter;
		[track1NameButton setTitleColor:RGBA(120, 120, 120, 1) forState: UIControlStateNormal];
		track1NameButton.backgroundColor = [UIColor clearColor];

		// TRACK 2 SLIDER
		track2VolumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(40.0f, trackSliderYPos, 160.0f, 57.0f)];
		track2VolumeSlider.backgroundColor = [UIColor clearColor];        
		[track2VolumeSlider setThumbImage: sliderThumbImage forState:UIControlStateNormal];
		[track2VolumeSlider setThumbImage: sliderThumbNotRecImage forState:UIControlStateDisabled];
		[track2VolumeSlider setMinimumTrackImage:minSliderImage forState:UIControlStateNormal];
		[track2VolumeSlider setMaximumTrackImage:maxSliderImage forState:UIControlStateNormal];
		track2VolumeSlider.minimumValue = VOLUME_MIN;
		track2VolumeSlider.maximumValue = VOLUME_MAX;
		track2VolumeSlider.continuous = YES;
		[track2VolumeSlider addTarget:self action:@selector(didMoveTrack2VolumeSlider) forControlEvents:UIControlEventValueChanged];
		track2VolumeSlider.transform = trans;
		
		track2NumberButton = [UIButton buttonWithType:UIButtonTypeCustom];
		track2NumberButton.frame = CGRectMake(80.25f, trackNumberYPos, 79.25f, 20.0f);
		track2NumberButton.titleLabel.font = [UIFont fontWithName:@"GrixelAcme7WideXtnd" size:8.0f];
		track2NumberButton.backgroundColor = [UIColor clearColor];
		track2NumberButton.titleLabel.textAlignment = UITextAlignmentCenter;
		[track2NumberButton setTitle:@"2" forState:UIControlStateNormal];
		[track2NumberButton setTitleColor:RGBA(120, 120, 120, 1) forState: UIControlStateNormal];
		
		track2NameButton = [UIButton buttonWithType:UIButtonTypeCustom];
		track2NameButton.frame = CGRectMake(85.25f, trackNameYPos, 69.25f, 20.0f);
		track2NameButton.titleLabel.font = [UIFont fontWithName:@"GrixelAcme7WideXtnd" size:8.0f];
		track2NameButton.titleLabel.textAlignment = UITextAlignmentCenter;
		[track2NameButton setTitleColor:RGBA(120, 120, 120, 1) forState: UIControlStateNormal];
		track2NameButton.backgroundColor = [UIColor clearColor];
		
		// TRACK 3 SLIDER
		track3VolumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(120.0f, trackSliderYPos, 160.0f, 57.0f)];
		track3VolumeSlider.backgroundColor = [UIColor clearColor];        
		[track3VolumeSlider setThumbImage: sliderThumbImage forState:UIControlStateNormal];
		[track3VolumeSlider setThumbImage: sliderThumbNotRecImage forState:UIControlStateDisabled];
		[track3VolumeSlider setMinimumTrackImage:minSliderImage forState:UIControlStateNormal];
		[track3VolumeSlider setMaximumTrackImage:maxSliderImage forState:UIControlStateNormal];
		track3VolumeSlider.minimumValue = VOLUME_MIN;
		track3VolumeSlider.maximumValue = VOLUME_MAX;
		track3VolumeSlider.continuous = YES;
		[track3VolumeSlider addTarget:self action:@selector(didMoveTrack3VolumeSlider) forControlEvents:UIControlEventValueChanged];
		track3VolumeSlider.transform = trans;
		
		track3NumberButton = [UIButton buttonWithType:UIButtonTypeCustom];
		track3NumberButton.frame = CGRectMake(160.5f, trackNumberYPos, 79.25f, 20.0f);
		track3NumberButton.titleLabel.font = [UIFont fontWithName:@"GrixelAcme7WideXtnd" size:8.0f];
		track3NumberButton.backgroundColor = [UIColor clearColor];
		track3NumberButton.titleLabel.textAlignment = UITextAlignmentCenter;
		[track3NumberButton setTitle:@"3" forState:UIControlStateNormal];
		[track3NumberButton setTitleColor:RGBA(120, 120, 120, 1) forState: UIControlStateNormal];
		
		track3NameButton = [UIButton buttonWithType:UIButtonTypeCustom];
		track3NameButton.frame = CGRectMake(165.5f, trackNameYPos, 69.25f, 20.0f);
		track3NameButton.titleLabel.font = [UIFont fontWithName:@"GrixelAcme7WideXtnd" size:8.0f];
		track3NameButton.titleLabel.textAlignment = UITextAlignmentCenter;
		[track3NameButton setTitleColor:RGBA(120, 120, 120, 1) forState:UIControlStateNormal];
		track3NameButton.backgroundColor = [UIColor clearColor];
		
		// TRACK 4 SLIDER
		track4VolumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(200.0f, trackSliderYPos, 160.0f, 57.0f)];
		track4VolumeSlider.backgroundColor = [UIColor clearColor];        
		[track4VolumeSlider setThumbImage: sliderThumbImage forState:UIControlStateNormal];
		[track4VolumeSlider setThumbImage: sliderThumbNotRecImage forState:UIControlStateDisabled];
		[track4VolumeSlider setMinimumTrackImage:minSliderImage forState:UIControlStateNormal];
		[track4VolumeSlider setMaximumTrackImage:maxSliderImage forState:UIControlStateNormal];
		track4VolumeSlider.minimumValue = VOLUME_MIN;
		track4VolumeSlider.maximumValue = VOLUME_MAX;
		track4VolumeSlider.continuous = YES;
		[track4VolumeSlider addTarget:self action:@selector(didMoveTrack4VolumeSlider) forControlEvents:UIControlEventValueChanged];
		track4VolumeSlider.transform = trans;
		
		track4NumberButton = [UIButton buttonWithType:UIButtonTypeCustom];
		track4NumberButton.frame = CGRectMake(240.75f, trackNumberYPos, 79.25f, 20.0f);
		track4NumberButton.titleLabel.font = [UIFont fontWithName:@"GrixelAcme7WideXtnd" size:8.0f];
		track4NumberButton.backgroundColor = [UIColor clearColor];
		track4NumberButton.titleLabel.textAlignment = UITextAlignmentCenter;
		[track4NumberButton setTitle:@"4" forState:UIControlStateNormal];
		[track4NumberButton setTitleColor:RGBA(120, 120, 120, 1) forState:UIControlStateNormal];
		
		track4NameButton = [UIButton buttonWithType:UIButtonTypeCustom];
		track4NameButton.frame = CGRectMake(245.75f, trackNameYPos, 69.25f, 20.0f);
		track4NameButton.titleLabel.font = [UIFont fontWithName:@"GrixelAcme7WideXtnd" size:8.0f];
		track4NameButton.titleLabel.textAlignment = UITextAlignmentCenter;
		[track4NameButton setTitleColor:RGBA(120, 120, 120, 1) forState:UIControlStateNormal];
		track4NameButton.backgroundColor = [UIColor clearColor];

		//-------------------------------------------------------------------
		// SETUP BPM SLIDER
		ypos = 278.0f;
		
		// Add slider background
		UIImageView *bpmSliderBgView = [[UIImageView alloc] initWithFrame:CGRectMake(40.0f, ypos, 240.0f, 6.0f)];
		bpmSliderBgView.image = [UIImage imageNamed:@"bpm-slider-bg.png"];
		
		UIImageView *bpmThumbBg = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 80.0f, 52.0f)];
		bpmThumbBg.image = [UIImage imageNamed:@"bpm-indicator.png"];
		UIGraphicsBeginImageContext(bpmThumbBg.bounds.size);
		[bpmThumbBg.layer renderInContext:UIGraphicsGetCurrentContext()];
		UIImage *bpmThumbBgImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		[bpmThumbBg release];
		bpmThumbBg = nil;
		 
		UIView *clearView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 10.0f)];
		clearView.backgroundColor = [UIColor clearColor];
		UIGraphicsBeginImageContext(clearView.bounds.size);
		[clearView.layer renderInContext:UIGraphicsGetCurrentContext()];
		UIImage *clearImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		[clearView release];
		clearView = nil;
		
		bpmSlider = [[UISlider alloc] initWithFrame:CGRectMake(0.0f, ypos - 28.0f, 320.0f, 0.0f)];
		bpmSlider.backgroundColor = [UIColor clearColor]; 
		[bpmSlider setThumbImage:bpmThumbBgImage forState:UIControlStateNormal];
		[bpmSlider setMinimumTrackImage:clearImage forState:UIControlStateNormal];
		[bpmSlider setMaximumTrackImage:clearImage forState:UIControlStateNormal];
		bpmSlider.minimumValue = TEMPO_MIN;
		bpmSlider.maximumValue = TEMPO_MAX;
		bpmSlider.continuous = YES;
		[bpmSlider addTarget:self action:@selector(didMoveTempoSlider) forControlEvents:UIControlEventValueChanged];
		
		UILabel *bpmSliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, ypos - 15.0f, 320.0f, 10.0f)];
		bpmSliderLabel.backgroundColor = [UIColor clearColor];
		bpmSliderLabel.font = [UIFont fontWithName:@"GrixelAcme7Wide" size:8];
		bpmSliderLabel.text = @"BPM";
		bpmSliderLabel.textColor = RGBA(200, 200, 200, 1);
		bpmSliderLabel.textAlignment = UITextAlignmentCenter;
		
		bpmLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 80.0f, 31.0f)];
		bpmLabel.backgroundColor = [UIColor clearColor];
		bpmLabel.textColor = RGBA(40, 40, 40, 1);
		bpmLabel.textAlignment = UITextAlignmentCenter;
		bpmLabel.font = [UIFont fontWithName:@"GrixelAcme7Wide" size:24];
				
		UIButton *minusSign = [UIButton buttonWithType:UIButtonTypeCustom];
		minusSign.frame = CGRectMake(10.0f, ypos, 10.0f, 10.0f);
		[minusSign setImage:[UIImage imageNamed:@"minus-sign.png"] forState:UIControlStateNormal];
		UIButton *plusSign = [UIButton buttonWithType:UIButtonTypeCustom];
		plusSign.frame = CGRectMake(300.0f, ypos, 10.0f, 10.0f);
		[plusSign setImage:[UIImage imageNamed:@"plus-sign.png"] forState:UIControlStateNormal];
		
		//-------------------------------------------------------------------
		ypos = 292.0f;
		// SETUP TIME SLIDER
		// Create slider background
		UIView *sliderBgView = [[UIView alloc] initWithFrame:CGRectMake(120.0f, ypos - 50, 200.0f, 10.0f)];
		sliderBgView.backgroundColor = [UIColor clearColor];
		
		UIImageView *ticker1 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 10.0f)];
        ticker1.image = [UIImage imageNamed:@"playhead-ticker.png"];
		[sliderBgView addSubview:ticker1];

		UIGraphicsBeginImageContext(sliderBgView.bounds.size);
		[sliderBgView.layer renderInContext:UIGraphicsGetCurrentContext()];
		UIImage *sliderBgImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		[ticker1 release];
		[sliderBgView release];
		ticker1 = nil;
		sliderBgView = nil;
		
		timeSlider = [[UISlider alloc] initWithFrame:CGRectMake(120.0f, ypos, 200.0f, 0.0f)];
		timeSlider.backgroundColor = [UIColor clearColor];        
		[timeSlider setThumbImage: [UIImage imageNamed:@"playhead.png"] forState:UIControlStateNormal];
		[timeSlider setMinimumTrackImage:sliderBgImage forState:UIControlStateNormal];
		[timeSlider setMaximumTrackImage:sliderBgImage forState:UIControlStateNormal];
		timeSlider.minimumValue = TIMESLIDER_MIN;
		timeSlider.maximumValue = TIMESLIDER_MAX;
		timeSlider.continuous = YES;
		[timeSlider addTarget:self action:@selector(didMoveTimeSlider) forControlEvents:UIControlEventValueChanged];

		// SETUP ELAPSED TIME LABEL		
		elapsedTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, ypos + 5.0f, 200.0f, 16.0f)];
		elapsedTimeLabel.backgroundColor = [UIColor clearColor];
		elapsedTimeLabel.font = [UIFont fontWithName:@"GrixelAcme7WideXtnd" size:8.0f];
		elapsedTimeLabel.textColor = RGBA(200, 200, 200, 1);
		
		ypos = 315.0f;
		
		//-------------------------------------------------------------------
		// SETUP PLAYER BUTTONS
		
		rewindButton = [UIButton buttonWithType:UIButtonTypeCustom];
		rewindButton.frame = CGRectMake(0.0f, ypos, 79.25f, 99.0f);
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
		playButton.frame = CGRectMake(80.25f, ypos, 79.25f, 99.0f);
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
		fastForwardButton.frame = CGRectMake(160.5f, ypos, 79.25f, 99.0f);
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
		recordButton.frame = CGRectMake(240.75f, ypos, 79.25f, 99.0f);
		recordButton.backgroundColor = RGBA(40, 40, 40, 1);
		[recordButton setImage:[UIImage imageNamed:@"rec-btn.png"] forState:UIControlStateNormal];
		[recordButton setImage:[UIImage imageNamed:@"rec-btn-inactive.png"] forState:UIControlStateDisabled];
		[recordButton setImage:[UIImage imageNamed:@"rec-btn-selected.png"] forState:UIControlStateSelected];
		[recordButton addTarget:self action:@selector(tappedRecordButton:) forControlEvents:UIControlEventTouchUpInside];
		recordButton.enabled = NO;
		
		recordLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, recordButton.bounds.size.height - 30.0f, recordButton.bounds.size.width, 10.0f)];
		recordLabel.backgroundColor = [UIColor clearColor];
		recordLabel.font = [UIFont fontWithName:@"GrixelAcme7WideXtnd" size:8.0f];
		recordLabel.textAlignment = UITextAlignmentCenter;
		recordLabel.text = @"REC";
		recordLabel.textColor = RGBA(120, 120, 120, 1);
		[recordButton addSubview:recordLabel];
		
		[self addSubview:rewindButton];
		[self addSubview:playButton];
		[self addSubview:fastForwardButton];
		[self addSubview:recordButton];
		
		[self addSubview:shareButton];
		[self addSubview:volumeButton];
		[self addSubview:pitchButton];
		[self addSubview:saveButton];
		[self addSubview:bgView];
		
		// Track Sliders
		[self addSubview:track1BgView];
		[self addSubview:track2BgView];
		[self addSubview:track3BgView];
		[self addSubview:track4BgView];
		[self addSubview:track1VolumeSlider];
		[self addSubview:track1NumberButton];
		[self addSubview:track1NameButton];
		[self addSubview:track2VolumeSlider];
		[self addSubview:track2NumberButton];
		[self addSubview:track2NameButton];
		[self addSubview:track3VolumeSlider];
		[self addSubview:track3NumberButton];
		[self addSubview:track3NameButton];
		[self addSubview:track4VolumeSlider];
		[self addSubview:track4NumberButton];
		[self addSubview:track4NameButton];

		[self addSubview:bpmSliderBgView];
		[self addSubview:bpmSliderLabel];
		[self addSubview:bpmSlider];
		[self addSubview:minusSign];
		[self addSubview:plusSign];
		
		[self addSubview:elapsedTimeLabel];
		[self addSubview:timeSlider];
		
		
		[bgView release];
		[track1BgView release];
		[track2BgView release];
		[track3BgView release];
		[track4BgView release];
		[bpmSliderBgView release];
		[bpmSliderLabel release];
		
		//-----------------------------------------------------------------------------------
		// SETUP ALERT
		notRecordedAlert = [[UIAlertView alloc] initWithTitle:nil 
													  message:@"None of the tracks has been recorded." 
													 delegate:self 
											cancelButtonTitle:@"OK" 
											otherButtonTitles:nil];
    }
    return self;
}

-(void) fillInViewValues
{
	// Track Volume Levels
	int i = 0;
	TrackObject *aTrackObject;
	InstrumentObject *anInstrumentObject;
	
	// Track 1
	aTrackObject = [trackObjectArray objectAtIndex:i];
	anInstrumentObject = [instrumentArray objectAtIndex:aTrackObject.instrument];
	track1VolumeSlider.value = aTrackObject.volumeLevel;
	if(aTrackObject.isRecorded == YES)
	{
		[track1NameButton setTitle:[NSString stringWithFormat:@"%@", [anInstrumentObject name]] forState:UIControlStateNormal];
		[track1NameButton setTitleColor:RGBA(200, 200, 200, 1) forState:UIControlStateNormal];
		[track1NumberButton setTitleColor:RGBA(200, 200, 200, 1) forState:UIControlStateNormal];
		track1VolumeSlider.enabled = YES;
	}
	else
	{
		[track1NameButton setTitle:@"[ REC ]" forState:UIControlStateNormal];
		track1VolumeSlider.enabled = NO;
	}
	
	i++;
	// Track 2
	aTrackObject = [trackObjectArray objectAtIndex:i];
	anInstrumentObject = [instrumentArray objectAtIndex:aTrackObject.instrument];
	track2VolumeSlider.value = aTrackObject.volumeLevel;
	if(aTrackObject.isRecorded == YES)
	{
		[track2NameButton setTitle:[NSString stringWithFormat:@"%@", [anInstrumentObject name]] forState:UIControlStateNormal];
		[track2NameButton setTitleColor:RGBA(200, 200, 200, 1) forState:UIControlStateNormal];
		[track2NumberButton setTitleColor:RGBA(200, 200, 200, 1) forState:UIControlStateNormal];
		track2VolumeSlider.enabled = YES;
	}
	else
	{
		[track2NameButton setTitle:@"[ REC ]" forState:UIControlStateNormal];		
		track2VolumeSlider.enabled = NO;
	}
	
	i++;
	// Track 3
	aTrackObject = [trackObjectArray objectAtIndex:i];
	anInstrumentObject = [instrumentArray objectAtIndex:aTrackObject.instrument];
	track3VolumeSlider.value = aTrackObject.volumeLevel;
	if(aTrackObject.isRecorded == YES)
	{
		[track3NameButton setTitle:[NSString stringWithFormat:@"%@", [anInstrumentObject name]] forState:UIControlStateNormal];
		[track3NameButton setTitleColor:RGBA(200, 200, 200, 1) forState:UIControlStateNormal];
		[track3NumberButton setTitleColor:RGBA(200, 200, 200, 1) forState:UIControlStateNormal];
		track3VolumeSlider.enabled = YES;
	}
	else
	{
		[track3NameButton setTitle:@"[ REC ]" forState:UIControlStateNormal];		
		track3VolumeSlider.enabled = NO;
	}
	
	i++;
	// Track 4
	aTrackObject = [trackObjectArray objectAtIndex:i];
	anInstrumentObject = [drumKitArray objectAtIndex:aTrackObject.instrument];	
	track4VolumeSlider.value = aTrackObject.volumeLevel;
	if(aTrackObject.isRecorded == YES)
	{
		[track4NameButton setTitle:@"BEATS" forState:UIControlStateNormal];
		[track4NameButton setTitleColor:RGBA(200, 200, 200, 1) forState:UIControlStateNormal];
		[track4NumberButton setTitleColor:RGBA(200, 200, 200, 1) forState:UIControlStateNormal];
		track4VolumeSlider.enabled = YES;
	}
	else
	{
		[track4NameButton setTitle:@"[ REC ]" forState:UIControlStateNormal];		
		track4VolumeSlider.enabled = NO;
	}
	
	// Tempo Slider
	bpmSlider.value = tempo;
	tempoTimeInterval = (float) 60.0f / (float) tempo;
	
	// Add tempo label
	[self addTempoLabel];
	
	// Time Slider
	timeSlider.value = (elapsedMin * 60) + elapsedSec;
	elapsedTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d / %02d:%02d", elapsedMin, elapsedSec, (int)RECORDING_MINUTES, (int)RECORDING_SECONDS];
}

-(void) addTempoLabel
{
	UIImageView *bpmThumbBg = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 80.0f, 52.0f)];
	bpmThumbBg.image = [UIImage imageNamed:@"bpm-indicator.png"];
	bpmLabel.text = [NSString stringWithFormat:@"%03d", tempo];
	[bpmThumbBg addSubview:bpmLabel];
	
	UIGraphicsBeginImageContext(bpmThumbBg.bounds.size);
	[bpmThumbBg.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *bpmThumbBgImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	[bpmThumbBg release];
	bpmThumbBg = nil;
	
	[bpmSlider setThumbImage:bpmThumbBgImage forState:UIControlStateNormal];
}

-(void) tappedShareSongButton:(id) sender
{
	UIActionSheet *shareActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" 
												   destructiveButtonTitle:nil 
														otherButtonTitles:@"Email", @"Post to Twitter", @"Post to Facebook", nil];
    shareActionSheet.tag = SHARESONGAS_TAG;
	shareActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [shareActionSheet showInView:self];
    [shareActionSheet release];
}
-(void) tappedSaveSongButton:(id) sender
{
	if(songID == -1)
	{
		[nc postNotificationName:@"didShowSaveNewSong" object:nil];
	}
	else 
	{
		UIActionSheet *saveActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" 
													   destructiveButtonTitle:nil 
															otherButtonTitles:@"Save New Version", @"Replace Song", nil];
		saveActionSheet.tag = SAVESONGAS_TAG;
		saveActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
		[saveActionSheet showInView:self];
		[saveActionSheet release];		
	}
}

-(void) tappedPitchButton:(id) sender
{	
	[nc postNotificationName:@"didSelectPitch" object:nil];
}

//-----------------------------------------------------------------------------------
// REWIND BUTTON IMPLEMENTATION
-(void) touchedDownRewindButton:(id) sender
{
	buttonMode = buttonStalling;
	
	if(prevRewindTapTime == nil)
	{
		prevRewindTapTime = [[NSDate date] retain];
	}
	else 
	{
		// Detected a double tap, go to beginning of the track
		if([[NSDate date] timeIntervalSinceDate:prevRewindTapTime] <= 0.5f)
			timeSlider.value = 0;			
		prevRewindTapTime = [[NSDate date] retain];
	}
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
	beatCounter = 0;
    
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
	if (playTimer != nil)
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
}

// Stop all track players
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
}

-(void) updatePlayControlState:(BOOL) isPlaying
{
    playButton.selected = isPlaying;
    shareButton.enabled = !isPlaying;
    saveButton.enabled = !isPlaying;
    volumeButton.enabled = !isPlaying;
    pitchButton.enabled = !isPlaying;
    
    if(isPlaying)
    {
        playLabel.textColor = RGBA(200, 200, 200, 1);
        shareLabel.textColor = RGBA(120, 120, 120, 1); 
        saveLabel.textColor = RGBA(120, 120, 120, 1); 
        volumeLabel.textColor = RGBA(120, 120, 120, 1); 
        pitchLabel.textColor = RGBA(120, 120, 120, 1); 
        
        [nc postNotificationName:@"didDisableRecordingTabBar" object:nil];
        [nc postNotificationName:@"didDisableTracksTabBar" object:nil];
        [nc postNotificationName:@"didDisableSongsTabBar" object:nil];
        [nc postNotificationName:@"didDisableSettingsTabBar" object:nil];
    }
    else
    {
        playLabel.textColor = RGBA(200, 200, 200, 1);
        shareLabel.textColor = RGBA(200, 200, 200, 1);
        saveLabel.textColor = RGBA(200, 200, 200, 1);
        volumeLabel.textColor = RGBA(255, 255, 0, 1);
        pitchLabel.textColor = RGBA(200, 200, 200, 1);
        
        [nc postNotificationName:@"didEnableRecordingTabBar" object:nil];
        [nc postNotificationName:@"didEnableTracksTabBar" object:nil];
        [nc postNotificationName:@"didEnableSongsTabBar" object:nil];
        [nc postNotificationName:@"didEnableSettingsTabBar" object:nil];
    }
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
	
    // Play all recorded tracks
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
                // Get position of player based on the slider position
                int posSlider = (int)timeSlider.value - 1.0f;
                int posFlag;            // Flag at posSlider position
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
	elapsedMin = (int)timeSlider.value / 60;
	elapsedSec = (int)timeSlider.value % 60;
	elapsedTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d / %02d:%02d", elapsedMin, elapsedSec, (int)RECORDING_MINUTES, (int)RECORDING_SECONDS];
	
	NSDictionary *timeDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithInt:elapsedMin], @"elapsedMin",
							  [NSNumber numberWithInt:elapsedSec], @"elapsedSec",
							  nil];
	[nc postNotificationName:@"didMoveVolumeTimeSlider" object:timeDict];
}
//-----------------------------------------------------------------------------------
// TEMPO
-(void) didMoveTempoSlider
{
	tempo = bpmSlider.value;
	tempoTimeInterval = (float) 60.0f / (float) tempo;
	[self addTempoLabel];
	
	[nc postNotificationName:@"didChangeTempo" object:[NSNumber numberWithInt:tempo]];
}

//-----------------------------------------------------------------------------------
// VOLUME SLIDERS
-(void) didMoveTrack1VolumeSlider
{
    int trackNumber = 0;
    
	TrackObject *aTrackObject = [trackObjectArray objectAtIndex:trackNumber];
	aTrackObject.volumeLevel = track1VolumeSlider.value;
	if(aTrackObject.isRecorded == YES)
		[aTrackObject.player setVolume:aTrackObject.volumeLevel];
	[trackObjectArray replaceObjectAtIndex:trackNumber withObject:aTrackObject];
    
    // Send notification to update delegate object
    NSDictionary *trackDict = [NSDictionary dictionaryWithObjectsAndKeys:
                               aTrackObject, @"trackObject",
                               [NSNumber numberWithInt:trackNumber], @"trackNumber",
                               nil];
	[nc postNotificationName:@"didUpdateTrack" object:trackDict];
}

-(void) didMoveTrack2VolumeSlider
{
    int trackNumber = 1;
    
	TrackObject *aTrackObject = [trackObjectArray objectAtIndex:trackNumber];
	aTrackObject.volumeLevel = track2VolumeSlider.value;
	if(aTrackObject.isRecorded == YES)
		[aTrackObject.player setVolume:aTrackObject.volumeLevel];
	[trackObjectArray replaceObjectAtIndex:trackNumber withObject:aTrackObject];
    
    // Send notification to update delegate object
    NSDictionary *trackDict = [NSDictionary dictionaryWithObjectsAndKeys:
                               aTrackObject, @"trackObject",
                               [NSNumber numberWithInt:trackNumber], @"trackNumber",
                               nil];
	[nc postNotificationName:@"didUpdateTrack" object:trackDict];
}

-(void) didMoveTrack3VolumeSlider
{
    int trackNumber = 2;
    
	TrackObject *aTrackObject = [trackObjectArray objectAtIndex:trackNumber];
	aTrackObject.volumeLevel = track3VolumeSlider.value;
	if(aTrackObject.isRecorded == YES)
		[aTrackObject.player setVolume:aTrackObject.volumeLevel];
	[trackObjectArray replaceObjectAtIndex:trackNumber withObject:aTrackObject];
    
    // Send notification to update delegate object
    NSDictionary *trackDict = [NSDictionary dictionaryWithObjectsAndKeys:
                               aTrackObject, @"trackObject",
                               [NSNumber numberWithInt:trackNumber], @"trackNumber",
                               nil];
	[nc postNotificationName:@"didUpdateTrack" object:trackDict];
}

-(void) didMoveTrack4VolumeSlider
{
    int trackNumber = 3;
    
	TrackObject *aTrackObject = [trackObjectArray objectAtIndex:trackNumber];
	aTrackObject.volumeLevel = track4VolumeSlider.value;	
	if(aTrackObject.isRecorded == YES)
		[aTrackObject.player setVolume:aTrackObject.volumeLevel];
	[trackObjectArray replaceObjectAtIndex:trackNumber withObject:aTrackObject];
    
    // Send notification to update delegate object
    NSDictionary *trackDict = [NSDictionary dictionaryWithObjectsAndKeys:
                               aTrackObject, @"trackObject",
                               [NSNumber numberWithInt:trackNumber], @"trackNumber",
                               nil];
	[nc postNotificationName:@"didUpdateTrack" object:trackDict];
}

//-----------------------------------------------------------------------------------
// SHARE/SAVE SONG
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	switch (actionSheet.tag) 
	{
		// SHARE SONG
		case SHARESONGAS_TAG:	
			// Email
			if (buttonIndex == 0) 
			{
				[nc postNotificationName:@"didShareSongEmail" object:nil];
			} 
			// Post to Twitter
			else if (buttonIndex == 1)
			{
			}
			// Post to Facebook
			else if (buttonIndex == 1)
			{
			}
			break;
		// SAVE SONG
		case SAVESONGAS_TAG:	
			// Save New Version button
			if (buttonIndex == 0) 
			{
				[nc postNotificationName:@"didShowSaveNewSong" object:nil];
			} 
			// Replace Song button
			else if (buttonIndex == 1)
			{
				[nc postNotificationName:@"didReplaceSong" object:nil];
			}
			break;
		default:
			break;
	}
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
	[shareLabel release];
	[saveLabel release];
	[volumeLabel release];
	[pitchLabel release];
	[track1VolumeSlider release];
	[track2VolumeSlider release];
	[track3VolumeSlider release];
	[track4VolumeSlider release];
	[elapsedTimeLabel release];
	[timeSlider release];
	[bpmSlider release];
	[bpmLabel release];
	[rewindLabel release];
	[playLabel release];
	[fastForwardLabel release];
	[recordLabel release];
	
	[playTimer invalidate];
    [playDrumsTimer invalidate];
	[rewTimer invalidate];
	[fwdTimer invalidate];
	
	[prevRewindTapTime release];
	[notRecordedAlert release];
}

@end
