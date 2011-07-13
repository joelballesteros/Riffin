//
//  RecordingNewBeatViewController.m
//  Solocaster
//
//  Created by Nikki Fernandez on 12/21/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import "RecordingNewBeatViewController.h"
#import "TrackObject.h"
#import "InstrumentObject.h"

#define TIME_MIN 0.0
#define TIME_MAX 270.0


@implementation RecordingNewBeatViewController

- (id) init
{
	if ((self = [super init])) 
	{
		[self initializeNotification];
		mainDelegate = (SolocasterAppDelegate *)[[UIApplication sharedApplication] delegate];
		[self didSelectRecordNewBeat];
	}
	return self;
}

-(void) initializeNotification
{
	nc = [NSNotificationCenter defaultCenter];

	[nc addObserver:self 
		   selector:@selector(didSelectRecordNewBeat) 
			   name:@"didSelectRecordNewBeat" 
			 object:nil];
	
	[nc addObserver:self 
		   selector:@selector(didCancelRecordNewBeat) 
			   name:@"didCancelRecordNewBeat" 
			 object:nil];
	
	[nc addObserver:self 
		   selector:@selector(didSaveRecordNewBeat:) 
			   name:@"didSaveRecordNewBeat" 
			 object:nil];
	
	[nc addObserver:self 
		   selector:@selector(didToggleLoopLengthSettings:) 
			   name:@"didToggleLoopLengthSettings" 
			 object:nil];
	
	[nc addObserver:self 
		   selector:@selector(didMoveNewBeatTimeSlider:) 
			   name:@"didMoveNewBeatTimeSlider" 
			 object:nil];
}

-(void) didSelectRecordNewBeat
{
	[nc postNotificationName:@"hideTabBarController" object:nil];
	
	if(recordingNewBeatView == nil)
	{
		recordingNewBeatView = [[RecordingNewBeatView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f)];
		[self.view addSubview:recordingNewBeatView];
	}
	
	recordingNewBeatView.drumKitArray = mainDelegate.drumKitArray;
	recordingNewBeatView.tempo = mainDelegate.tempo;
	recordingNewBeatView.loopLength = mainDelegate.loopLength;
    recordingNewBeatView.elapsedMin = mainDelegate.newBeatElapsedMin;
	recordingNewBeatView.elapsedSec = mainDelegate.newBeatElapsedSec;
	recordingNewBeatView.isRecordBeat = mainDelegate.isRecordBeat;
	[recordingNewBeatView fillInViewValues];
}

-(void) didCancelRecordNewBeat
{
	[nc postNotificationName:@"didSelectRecordingScreen" object:nil];
}

-(void) didSaveRecordNewBeat:(NSNotification *)note
{
    TrackObject *aTrackObject = [mainDelegate.trackObjectArray objectAtIndex:3];    // Track 4 is drum loop
    aTrackObject.isRecorded = YES;
    aTrackObject.volumeLevel = 1.0f;
    aTrackObject.pitchLevel = 0.0f;
    aTrackObject.drumPadArray = [note object];
    [mainDelegate.trackObjectArray replaceObjectAtIndex:3 withObject:aTrackObject];
    
	[nc postNotificationName:@"didSelectRecordingScreen" object:nil];
}

-(void) didToggleLoopLengthSettings:(NSNotification *) note
{
	mainDelegate.loopLength = [[note object] intValue];
}

-(void) didMoveNewBeatTimeSlider:(NSNotification *) note
{
	NSDictionary *timeDict = [note object];
	mainDelegate.newBeatElapsedMin = [[timeDict objectForKey:@"elapsedMin"] intValue];
	mainDelegate.newBeatElapsedSec = [[timeDict objectForKey:@"elapsedSec"] intValue];
}

- (void)didReceiveMemoryWarning 
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc 
{
    [super dealloc];
	[recordingNewBeatView release];
	
	[nc removeObserver:self name:@"didSelectRecordNewBeat" object:nil]; 
	[nc removeObserver:self name:@"didCancelRecordNewBeat" object:nil]; 
	[nc removeObserver:self name:@"didSaveRecordNewBeat" object:nil]; 
	[nc removeObserver:self name:@"didMoveNewBeatTimeSlider" object:nil]; 
}


@end
