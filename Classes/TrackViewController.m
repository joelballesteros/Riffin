//
//  TrackViewController.m
//  Solocaster
//
//  Created by Nikki Fernandez on 11/3/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import "TrackViewController.h"
#import "SolocasterAppDelegate.h"
#import "TrackObject.h"
#import "UICustomTabBarItem.h"

@implementation TrackViewController

@synthesize isLastViewVolume;

-(id) init
{
	if ((self = [super init]))
	{
		[self initializeNotification];
		mainDelegate = (SolocasterAppDelegate *)[[UIApplication sharedApplication] delegate];		
		[self didSelectVolume];
	}
	return self;
}

-(void) initializeNotification
{
	nc = [NSNotificationCenter defaultCenter];

	[nc addObserver:self 
		   selector:@selector(didSelectVolume) 
			   name:@"didSelectVolume" 
			 object:nil];	
	
	[nc addObserver:self 
		   selector:@selector(didSelectPitch) 
			   name:@"didSelectPitch" 
			 object:nil];
	
    [nc addObserver:self 
		   selector:@selector(didTapSongToShowTracks:) 
			   name:@"didTapSongToShowTracks" 
			 object:nil];
    
	[nc addObserver:self 
		   selector:@selector(didChangeTempo:) 
			   name:@"didChangeTempo" 
			 object:nil];	
	
	[nc addObserver:self 
		   selector:@selector(didShowSaveNewSong) 
			   name:@"didShowSaveNewSong" 
			 object:nil];

	[nc addObserver:self 
		   selector:@selector(didSaveNewSongWithName:) 
			   name:@"didSaveNewSongWithName" 
			 object:nil];
	
	[nc addObserver:self 
		   selector:@selector(didSaveNewSong:) 
			   name:@"didSaveNewSong" 
			 object:nil];
	
	[nc addObserver:self 
		   selector:@selector(didCancelSaveNewSong) 
			   name:@"didCancelSaveNewSong" 
			 object:nil];
	
	[nc addObserver:self 
		   selector:@selector(didReplaceSong) 
			   name:@"didReplaceSong" 
			 object:nil];
	
	[nc addObserver:self 
		   selector:@selector(didShareSongEmail) 
			   name:@"didShareSongEmail" 
			 object:nil];
	
	[nc addObserver:self 
		   selector:@selector(didMoveVolumeSlider:) 
			   name:@"didMoveVolumeSlider" 
			 object:nil];	

	[nc addObserver:self 
		   selector:@selector(didMovePitchSlider:) 
			   name:@"didMovePitchSlider" 
			 object:nil];

	[nc addObserver:self 
		   selector:@selector(didMoveVolumeTimeSlider:) 
			   name:@"didMoveVolumeTimeSlider" 
			 object:nil];

	[nc addObserver:self 
		   selector:@selector(didMovePitchTimeSlider:) 
			   name:@"didMovePitchTimeSlider" 
			 object:nil];
		
	[nc addObserver:self 
		   selector:@selector(didDisableTracksTabBar) 
			   name:@"didDisableTracksTabBar" 
			 object:nil];
	
	[nc addObserver:self 
		   selector:@selector(didEnableTracksTabBar) 
			   name:@"didEnableTracksTabBar" 
			 object:nil];
}

-(void) didSelectVolume
{
	isLastViewVolume = YES;
	
    if (tracksPitchView != nil) 
    {
        [tracksPitchView showVolume];
    }
	else if (tracksPitchView == nil) 
	{
		tracksPitchView = [[TracksPitchView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 460.0f)];
		[self.view addSubview:tracksPitchView];
        
        tracksPitchView.trackObjectArray = mainDelegate.trackObjectArray;
        tracksPitchView.instrumentArray = mainDelegate.instrumentArray;
        tracksPitchView.drumKitArray = mainDelegate.drumKitArray;
        tracksPitchView.tempo = mainDelegate.tempo;
        tracksPitchView.loopLength = mainDelegate.loopLength;
        tracksPitchView.songID = mainDelegate.songID;
        tracksPitchView.elapsedMin = mainDelegate.pitchElapsedMin;
        tracksPitchView.elapsedSec = mainDelegate.pitchElapsedSec;
        [tracksPitchView fillInViewValues];	
        [tracksPitchView showVolume];
	}
    
    /*
	if (tracksVolumeView == nil) 
	{
		tracksVolumeView = [[TracksVolumeView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 460.0f)];
		[self.view addSubview:tracksVolumeView];
	}
	
	tracksVolumeView.trackObjectArray = mainDelegate.trackObjectArray;
	tracksVolumeView.instrumentArray = mainDelegate.instrumentArray;
	tracksVolumeView.drumKitArray = mainDelegate.drumKitArray;
	tracksVolumeView.tempo = mainDelegate.tempo;
	tracksVolumeView.loopLength = mainDelegate.loopLength;
	tracksVolumeView.songID = mainDelegate.songID;
	tracksVolumeView.elapsedMin = mainDelegate.volumeElapsedMin;
	tracksVolumeView.elapsedSec = mainDelegate.volumeElapsedSec;
	[tracksVolumeView fillInViewValues];

    
	if (tracksPitchView != nil) 
	{
		[tracksPitchView removeFromSuperview];
		tracksPitchView = nil;
	}	
*/
	
	if(saveNewSongView != nil)
	{
		[saveNewSongView removeFromSuperview];
		saveNewSongView = nil;
	}
	
	if(shareSongEmailView != nil)
	{
		[shareSongEmailView removeFromSuperview];
		shareSongEmailView = nil;
	}
}

-(void) didSelectPitch
{	
	isLastViewVolume = NO;
	
    if (tracksPitchView != nil) 
    {
        tracksPitchView = nil;
    }

	if (tracksPitchView == nil) 
	{
		tracksPitchView = [[TracksPitchView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 460.0f)];
		[self.view addSubview:tracksPitchView];
	}
	
	tracksPitchView.trackObjectArray = mainDelegate.trackObjectArray;
	tracksPitchView.instrumentArray = mainDelegate.instrumentArray;
	tracksPitchView.drumKitArray = mainDelegate.drumKitArray;
	tracksPitchView.tempo = mainDelegate.tempo;
	tracksPitchView.loopLength = mainDelegate.loopLength;
	tracksPitchView.songID = mainDelegate.songID;
	tracksPitchView.elapsedMin = mainDelegate.pitchElapsedMin;
	tracksPitchView.elapsedSec = mainDelegate.pitchElapsedSec;
	[tracksPitchView fillInViewValues];	
	
	if (tracksVolumeView != nil) 
	{
		[tracksVolumeView removeFromSuperview];
		tracksVolumeView = nil;
	}
	
	if(saveNewSongView != nil)
	{
		[saveNewSongView removeFromSuperview];
		saveNewSongView = nil;
	}
	
	if(shareSongEmailView != nil)
	{
		[shareSongEmailView removeFromSuperview];
		shareSongEmailView = nil;
	}
}

-(void) didTapSongToShowTracks:(NSNotification *) note
{
	NSDictionary *songDict = [note object];
	// Update the delegate object
	mainDelegate.trackObjectArray = [songDict objectForKey:@"trackObjectArray"];
	mainDelegate.songID = [[songDict objectForKey:@"songID"] intValue];
	mainDelegate.songName = [songDict objectForKey:@"songName"];
    
   // Set current track to Track 1
	int i;
	TrackObject *aTrackObject;
	for(i = 0; i < [mainDelegate.trackObjectArray count]; i++)
	{
		aTrackObject = [mainDelegate.trackObjectArray objectAtIndex:i];
		if(aTrackObject.isCurrentTrack == YES)
		{
			if(i == 0)
			{
				break;
			}
			else 
			{
				aTrackObject.isCurrentTrack = NO;
				[mainDelegate.trackObjectArray replaceObjectAtIndex:i withObject:aTrackObject];
				
				// Set Track 1
				aTrackObject = [mainDelegate.trackObjectArray objectAtIndex:0];
				aTrackObject.isCurrentTrack = YES;
				[mainDelegate.trackObjectArray replaceObjectAtIndex:0 withObject:aTrackObject];
			}
		}
	}
	
	self.tabBarController.selectedIndex = 1;
	[self didSelectPitch];
}

-(void) didChangeTempo:(NSNotification *)note
{
	mainDelegate.tempo = [[note object] intValue];
}

-(void) didShowSaveNewSong
{
	if(saveNewSongView == nil)
	{
		saveNewSongView = [[SaveNewSongView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f)];
		saveNewSongView.trackObjectArray = mainDelegate.trackObjectArray;
		saveNewSongView.songName = mainDelegate.songName;
		[saveNewSongView fillInViewValues];
		[self.view addSubview:saveNewSongView];
	}
	
	if (tracksVolumeView != nil) 
	{
		[tracksVolumeView removeFromSuperview];
		tracksVolumeView = nil;
	}
	
	if (tracksPitchView != nil) 
	{
		[tracksPitchView removeFromSuperview];
		tracksPitchView = nil;
	}
	
	if(shareSongEmailView != nil)
	{
		[shareSongEmailView removeFromSuperview];
		shareSongEmailView = nil;
	}
}

-(void) didSaveNewSongWithName:(NSNotification *)note
{
	if(saveNewSongView == nil)
	{
		saveNewSongView = [[SaveNewSongView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f)];
	}
	
	mainDelegate.songName = [note object];
	saveNewSongView.trackObjectArray = [mainDelegate.trackObjectArray copy];
	saveNewSongView.songName = mainDelegate.songName;
    saveNewSongView.loopLength = mainDelegate.loopLength;
    saveNewSongView.tempo = mainDelegate.tempo;
    
    [saveNewSongView saveNewSong];
}	

-(void) didSaveNewSong:(NSNotification *)note
{
	NSDictionary *songDict = [note object];
	mainDelegate.songID = [[songDict objectForKey:@"songID"] intValue];
	mainDelegate.songName = [songDict objectForKey:@"songName"];
	
	if(self.tabBarController.selectedIndex == 0) // Recording Tab
	{
		[nc postNotificationName:@"didSelectRecordingScreen" object:nil];
	}
	else if(self.tabBarController.selectedIndex == 1) // Mix Tab
	{
		if(isLastViewVolume)
			[self didSelectVolume];
		else 
			[self didSelectPitch];
	}
}

-(void) didCancelSaveNewSong
{
	if(self.tabBarController.selectedIndex == 0) // Recording Tab
	{
		[nc postNotificationName:@"didSelectRecordingScreen" object:nil];
	}
	else if(self.tabBarController.selectedIndex == 1) // Mix Tab
	{
		if(isLastViewVolume)
			[self didSelectVolume];
		else 
			[self didSelectPitch];
	}
}

-(void) didReplaceSong
{
	// Song has not been opened yet. There is no song to replace version.
	if(mainDelegate.songID == -1)
	{
		[self didShowSaveNewSong];
	}
	else 
	{
		replaceSong = [[ReplaceSong alloc] init];
		replaceSong.updatedTracks = [mainDelegate.trackObjectArray copy];
		replaceSong.songID = mainDelegate.songID;
        replaceSong.loopLength = mainDelegate.loopLength;
        replaceSong.tempo = mainDelegate.tempo;
        
		[replaceSong update];	
	}
}

-(void) didShareSongEmail
{
	if(shareSongEmailView == nil)
	{
		shareSongEmailView = [[ShareSongEmailView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f)];
		[self.view addSubview:shareSongEmailView];
	}
}

-(void) didMoveVolumeSlider:(NSNotification *) note
{
	NSDictionary *volumeDict = [note object];
	TrackObject *aTrackObject = [mainDelegate.trackObjectArray objectAtIndex:[[volumeDict objectForKey:@"trackNumber"] intValue]];
	aTrackObject.volumeLevel = [[volumeDict objectForKey:@"volumeLevel"] floatValue];

	[mainDelegate.trackObjectArray replaceObjectAtIndex:[[volumeDict objectForKey:@"trackNumber"] intValue] withObject:aTrackObject];
}

-(void) didMovePitchSlider:(NSNotification *) note
{
	NSDictionary *pitchDict = [note object];
	TrackObject *aTrackObject = [mainDelegate.trackObjectArray objectAtIndex:[[pitchDict objectForKey:@"trackNumber"] intValue]];
	aTrackObject.pitchLevel = [[pitchDict objectForKey:@"pitchLevel"] floatValue];
	
	[mainDelegate.trackObjectArray replaceObjectAtIndex:[[pitchDict objectForKey:@"trackNumber"] intValue] withObject:aTrackObject];
}

-(void) didMoveVolumeTimeSlider:(NSNotification *) note
{
	NSDictionary *timeDict = [note object];
	mainDelegate.volumeElapsedMin = [[timeDict objectForKey:@"elapsedMin"] intValue];
	mainDelegate.volumeElapsedSec = [[timeDict objectForKey:@"elapsedSec"] intValue];
}

-(void) didMovePitchTimeSlider:(NSNotification *) note
{
	NSDictionary *timeDict = [note object];
	mainDelegate.pitchElapsedMin = [[timeDict objectForKey:@"elapsedMin"] intValue];
	mainDelegate.pitchElapsedSec = [[timeDict objectForKey:@"elapsedSec"] intValue];	
}

-(void) didDisableTracksTabBar
{
	self.tabBarItem.enabled = NO;
}

-(void) didEnableTracksTabBar
{
	self.tabBarItem.enabled = YES;	
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



- (void)dealloc 
{
    [super dealloc];
	
	[tracksVolumeView release];
	[tracksPitchView release];
	[saveNewSongView release];
	[shareSongEmailView release];
	[replaceSong release];
	
	[nc removeObserver:self name:@"didSelectVolume" object:nil]; 
	[nc removeObserver:self name:@"didSelectPitch" object:nil]; 
	[nc removeObserver:self name:@"didTapSongToShowTracks" object:nil]; 	
	[nc removeObserver:self name:@"didChangeTempo" object:nil]; 	
	
	[nc removeObserver:self name:@"didShowSaveNewSong" object:nil]; 
	[nc removeObserver:self name:@"didSaveNewSong" object:nil]; 
	[nc removeObserver:self name:@"didSaveNewSongWithName" object:nil]; 
	[nc removeObserver:self name:@"didCancelSaveNewSong" object:nil]; 
	[nc removeObserver:self name:@"didReplaceSong" object:nil]; 
	[nc removeObserver:self name:@"didShareSongEmail" object:nil]; 
	
	[nc removeObserver:self name:@"didMoveVolumeSlider" object:nil]; 
	[nc removeObserver:self name:@"didMovePitchSlider" object:nil]; 
	[nc removeObserver:self name:@"didMoveVolumeTimeSlider" object:nil]; 
	[nc removeObserver:self name:@"didMovePitchTimeSlider" object:nil]; 
	
	[nc removeObserver:self name:@"didDisableTracksTabBar" object:nil]; 	
	[nc removeObserver:self name:@"didEnableTracksTabBar" object:nil]; 
}


@end
