//
//  SettingsView.m
//  Solocaster
//
//  Created by Nikki Fernandez on 11/4/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import "SettingsView.h"
#import <QuartzCore/QuartzCore.h>
#import "TrackObject.h"
#import "InstrumentObject.h"
#import "UICustomSwitch.h"
#import "CustomUISwitch.h"

@implementation SettingsView

@synthesize isRecordBeat;
@synthesize isRecordInstrument;

// Color Macro
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) 
	{
		self.backgroundColor = [UIColor blackColor];
		nc = [NSNotificationCenter defaultCenter];
		
		float ypos = 0.0f;
		
		//-------------------------------------------------------------------
		// SETUP SETTINGS BAR
		UIView *settingsBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, ypos, 320.0f, 50.0f)];
		settingsBarView.backgroundColor = RGBA(80, 80, 80, 1);
		[self addSubview:settingsBarView];
		
		UILabel *settingsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, ypos, 320.0f, settingsBarView.bounds.size.height)];
		settingsLabel.backgroundColor = [UIColor clearColor];
		settingsLabel.font = [UIFont fontWithName:@"GrixelAcme7Wide" size:24];
		settingsLabel.text = @"Settings";
		settingsLabel.textColor = RGBA(200, 200, 200, 1);
		settingsLabel.textAlignment = UITextAlignmentCenter;
		[settingsBarView addSubview:settingsLabel];
		[settingsLabel release];
		
		// SETUP INFORMATION BUTTON
		UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
		infoButton.frame = CGRectMake(280.0f, 10.0f, 30.0f, 30.0f);
		infoButton.backgroundColor = [UIColor clearColor];
		[infoButton addTarget:self action:@selector(tappedInfoButton) forControlEvents:UIControlEventTouchUpInside];
		[settingsBarView addSubview:infoButton];
		[settingsBarView release];
		
		ypos += settingsBarView.bounds.size.height;
		//-------------------------------------------------------------------
		UIView *settingsBgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, ypos + 1.0f, 320.0f, 460.0f - ypos)];
		settingsBgView.backgroundColor = RGBA(80, 80, 80, 1);
		[self addSubview:settingsBgView];
		
		// SETUP METRONOME LABEL
		UILabel *metronomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, ypos + 10.0f, 320.0f, 20.0f)];
		metronomeLabel.backgroundColor = [UIColor clearColor];
		metronomeLabel.font = [UIFont fontWithName:@"GrixelAcme7Wide" size:16];
		metronomeLabel.text = @"Metronome Audible";
		metronomeLabel.textColor = RGBA(200, 200, 200, 1);
		metronomeLabel.textAlignment = UITextAlignmentLeft;
		[self addSubview:metronomeLabel];
		[metronomeLabel release];
		
		ypos += metronomeLabel.bounds.size.height + 15.0f;
		
		UIView *tableBgView = [[UIView alloc] initWithFrame:CGRectMake(10.0f, ypos, 300.0f, 80.0f)];
		tableBgView.backgroundColor = RGBA(160, 160, 160, 1);
		tableBgView.layer.borderColor = (RGBA(40, 40, 40, 1)).CGColor;
		tableBgView.layer.cornerRadius = 8.0f;
		tableBgView.layer.borderWidth = 1.0f;
		[self addSubview:tableBgView];
		
		UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 40.0f, 300.0f, 1.0f)];
		lineView.backgroundColor = RGBA(40, 40, 40, 1);
		[tableBgView addSubview:lineView];
		[lineView release];
		
		// SETUP RECORD BEAT SETTING
		UILabel *recordBeatLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 10.0f, 300.0f, 20.0f)];
		recordBeatLabel.backgroundColor = [UIColor clearColor];
		recordBeatLabel.font = [UIFont fontWithName:@"GrixelAcme7Wide" size:16];
		recordBeatLabel.text = @"Rec. Beat";
		recordBeatLabel.textColor = RGBA(80, 80, 80, 1);
		recordBeatLabel.textAlignment = UITextAlignmentLeft;
		[tableBgView addSubview:recordBeatLabel];		
		[recordBeatLabel release];
		
		recordBeatSwitch = [[CustomUISwitch alloc] initWithFrame:CGRectMake(210.0f, 7.0f, 30.0f, 20.0f)];
		[recordBeatSwitch addTarget:self action:@selector(didSwitchRecordBeat) forControlEvents:UIControlEventTouchUpInside];
		[tableBgView addSubview:recordBeatSwitch];
		
		// SETUP RECORD INSTRUMENT SETTING
		UILabel *recordInstrumentLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 50.0f, 300.0f, 20.0f)];
		recordInstrumentLabel.backgroundColor = [UIColor clearColor];
		recordInstrumentLabel.font = [UIFont fontWithName:@"GrixelAcme7Wide" size:16];
		recordInstrumentLabel.text = @"Rec. Instrument";
		recordInstrumentLabel.textColor = RGBA(80, 80, 80, 1);
		recordInstrumentLabel.textAlignment = UITextAlignmentLeft;
		[tableBgView addSubview:recordInstrumentLabel];		
		[recordInstrumentLabel release];

		recordInstrumentSwitch = [[CustomUISwitch alloc] initWithFrame:CGRectMake(210.0f, 48.0f, 30.0f, 20.0f)];
		[recordInstrumentSwitch addTarget:self action:@selector(didSwitchRecordInstrument) forControlEvents:UIControlEventTouchUpInside];
		[tableBgView addSubview:recordInstrumentSwitch];
        
        // Getting Started/Instructions
        UILabel *instructionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 180.0f, 320.0f, 20.0f)];
		instructionsLabel.backgroundColor = [UIColor clearColor];
		instructionsLabel.font = [UIFont fontWithName:@"GrixelAcme7Wide" size:16];
		instructionsLabel.text = @"Getting Started";
		instructionsLabel.textColor = RGBA(200, 200, 200, 1);
		instructionsLabel.textAlignment = UITextAlignmentLeft;
		[self addSubview:instructionsLabel];
		[instructionsLabel release];
        
        UITextView *instructionsText = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, 205.0f, 300.0f, 130.0f)];
        [instructionsText setBackgroundColor: RGBA(160, 160, 160, 1)];
        [instructionsText setFont:[UIFont fontWithName:@"GrixelAcme7WideXtnd" size:10]];
        [instructionsText setTextAlignment:UITextAlignmentLeft];
        [instructionsText setEditable:NO];
        [[instructionsText layer] setBorderColor:[[UIColor blackColor] CGColor]];
        [[instructionsText layer] setBorderWidth:1.0];
        [[instructionsText layer] setCornerRadius:10];
        [instructionsText setClipsToBounds: YES];
        [instructionsText setText:@"Instructions here..."];
        [self addSubview:instructionsText];
		
		[tableBgView release];
	}
    return self;
}

-(void) fillInViewValues
{
	[recordBeatSwitch setOn:isRecordBeat animated:YES];
	[recordInstrumentSwitch setOn:isRecordInstrument animated:YES];
}

-(void) tappedInfoButton
{
	[nc postNotificationName:@"didShowAbout" object:nil];
}

-(void) didSwitchRecordBeat
{
	isRecordBeat = [recordBeatSwitch isOn];
	[nc postNotificationName:@"didSwitchRecordBeatSettings" object:[NSNumber numberWithBool:isRecordBeat]];
}

-(void) didSwitchRecordInstrument
{
	isRecordInstrument = [recordInstrumentSwitch isOn];
	[nc postNotificationName:@"didSwitchRecordInstrumentSettings" object:[NSNumber numberWithBool:isRecordInstrument]];
}

- (void)dealloc 
{
    [super dealloc];
	[recordBeatSwitch release];
	[recordInstrumentSwitch release];
}

@end
