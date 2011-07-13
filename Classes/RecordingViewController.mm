    //
//  RecordingViewController.m
//  Solocaster
//
//  Created by Nikki Fernandez on 11/2/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import "RecordingViewController.h"
#import "TrackViewController.h"
#import "SolocasterAppDelegate.h"
#import "TrackObject.h"
#import "UICustomTabBarItem.h"

#define TRACK_COUNT 4

@implementation RecordingViewController

#pragma mark Audio session callbacks_______________________

void MyPropertyListener(void* user_data, AudioSessionPropertyID property_id,  
                        UInt32 data_size, const void* property_data) 
{ 
    if(kAudioSessionProperty_AudioInputAvailable == property_id) 
    { 
        if(sizeof(UInt32) == data_size) 
        { 
            UInt32 input_is_available = *(UInt32*) property_data; 
            if(input_is_available) 
            { 
                NSLog(@"Input available");
                
            } 
            else 
            { 
                NSLog(@"NO INPUT");
                UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
                AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);  
            } 
        } 
    } 
} 


void RouteChangeListener(	void *                  inClientData,
                         AudioSessionPropertyID	inID,
                         UInt32                  inDataSize,
                         const void *            inData)
{
	//CFDictionaryRef dict = (CFDictionaryRef)inData;
	
	//CFStringRef oldRoute = CFDictionaryGetValue(dict, CFSTR(kAudioSession_AudioRouteChangeKey_OldRoute));
	
	UInt32 size = sizeof(CFStringRef);
	
	CFStringRef newRoute;
	OSStatus result = AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &newRoute);
    
	NSLog(@"result: %ld Route changed to %@", result, newRoute);
}

-(id) init
{
	if ((self = [super init]))
	{
        // Registers the audio route change listener callback function
        AudioSessionAddPropertyListener (
                                         kAudioSessionProperty_AudioRouteChange,
                                         RouteChangeListener,
                                         self
                                         );
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
        OSStatus propertySetError = 0;
        UInt32 allowMixing = true;
        propertySetError = AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(allowMixing), &allowMixing);
        
        //UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        //AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
        
        NSLog(@"Mixing: %ld", propertySetError); // This should be 0 or there was an issue somewhere
        
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        
		[self initializeNotification];
		mainDelegate = (SolocasterAppDelegate *)[[UIApplication sharedApplication] delegate];
		[self didSelectRecordingScreen];
	}
	return self;
}

-(void) initializeNotification
{
	nc = [NSNotificationCenter defaultCenter];
	
	[nc addObserver:self 
		   selector:@selector(didSelectRecordingScreen) 
			   name:@"didSelectRecordingScreen" 
			 object:nil];
	
	[nc addObserver:self 
		   selector:@selector(didSelectClearSong) 
			   name:@"didSelectClearSong" 
			 object:nil];
	
	[nc addObserver:self 
		   selector:@selector(didShowSaveNewSongInRecording) 
			   name:@"didShowSaveNewSongInRecording" 
			 object:nil];
	
	[nc addObserver:self 
		   selector:@selector(didReplaceSongInRecording) 
			   name:@"didReplaceSongInRecording" 
			 object:nil];
	
	[nc addObserver:self 
		   selector:@selector(didScrollTrackInstrument:) 
			   name:@"didScrollTrackInstrument" 
			 object:nil];
	
	[nc addObserver:self 
		   selector:@selector(didChangeTrackNumber:) 
			   name:@"didChangeTrackNumber" 
			 object:nil];	
	
	[nc addObserver:self 
		   selector:@selector(didMoveRecordingTimeSlider:) 
			   name:@"didMoveRecordingTimeSlider" 
			 object:nil];
	
	[nc addObserver:self 
		   selector:@selector(didUpdateTrack:) 
			   name:@"didUpdateTrack" 
			 object:nil];	
	
	[nc addObserver:self 
		   selector:@selector(didDisableRecordingTabBar) 
			   name:@"didDisableRecordingTabBar" 
			 object:nil];	
	
	[nc addObserver:self 
		   selector:@selector(didEnableRecordingTabBar) 
			   name:@"didEnableRecordingTabBar" 
			 object:nil];	
}

-(void) didSelectRecordingScreen
{		
	[nc postNotificationName:@"showTabBarController" object:nil];

	if (recordingScreenView == nil) 
	{
		recordingScreenView = [[RecordingScreenView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 460.0f)];
		[self.view addSubview:recordingScreenView];
	}
	
	recordingScreenView.songName = mainDelegate.songName;
	recordingScreenView.songID = mainDelegate.songID;
	recordingScreenView.trackObjectArray = mainDelegate.trackObjectArray;
	recordingScreenView.instrumentArray = mainDelegate.instrumentArray;
	recordingScreenView.drumKitArray = mainDelegate.drumKitArray;
	recordingScreenView.tempo = mainDelegate.tempo;
	recordingScreenView.isRecordInstrument = mainDelegate.isRecordInstrument;
	recordingScreenView.loopLength = mainDelegate.loopLength;
	recordingScreenView.elapsedMin = mainDelegate.recordingElapsedMin;
	recordingScreenView.elapsedSec = mainDelegate.recordingElapsedSec;
    recordingScreenView.songDurationMax = mainDelegate.songDurationMax;
	recordingScreenView.trackNumber = mainDelegate.recordingTrackNumber;
    [recordingScreenView fillInViewValues];	
}

-(void) didSelectClearSong
{
	// Recording new song should reset all variables
	mainDelegate.songID = -1;
	mainDelegate.songName = @"New Song 1";
	mainDelegate.volumeElapsedMin = 0;
	mainDelegate.volumeElapsedSec = 0;
	mainDelegate.pitchElapsedMin = 0;
	mainDelegate.pitchElapsedSec = 0;
	mainDelegate.recordingElapsedMin = 0;
	mainDelegate.recordingElapsedSec = 0;
	mainDelegate.newBeatElapsedMin = 0;
	mainDelegate.newBeatElapsedSec = 0;
	mainDelegate.recordingTrackNumber = 0;
	
	int i;
	TrackObject *aTrackObject;
    [mainDelegate.trackObjectArray removeAllObjects];
    mainDelegate.trackObjectArray = nil;
	mainDelegate.trackObjectArray = [[NSMutableArray alloc] initWithObjects:nil];
	for(i = 0; i < TRACK_COUNT; ++i)
	{
		aTrackObject = [[TrackObject alloc] init];
        aTrackObject.instrument = 0;
		aTrackObject.volumeLevel = 0.0f;
		aTrackObject.pitchLevel = 0.0f;
		aTrackObject.isRecorded = NO;
		aTrackObject.isCurrentTrack = NO;
		aTrackObject.player = nil;
        aTrackObject.drumPadArray = [[NSMutableArray alloc] initWithObjects:nil];
		
		// Initialize recordFlags to all '0' to indicate no recording
		char repeatString[mainDelegate.songDurationMax + 1];
		memset(repeatString, '0', mainDelegate.songDurationMax);
		repeatString[mainDelegate.songDurationMax] = 0;
		aTrackObject.recordFlags = [NSMutableString stringWithCString:repeatString encoding: NSUTF8StringEncoding];
		
		if(i == 0)
			aTrackObject.isCurrentTrack = YES;
		
		[mainDelegate.trackObjectArray addObject:aTrackObject];
		[aTrackObject release];
	}
	[self didSelectRecordingScreen];
}

-(void) didShowSaveNewSongInRecording
{
	if(saveNewSongView == nil)
	{
		saveNewSongView = [[SaveNewSongView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f)];
		saveNewSongView.trackObjectArray = mainDelegate.trackObjectArray;
		saveNewSongView.songName = mainDelegate.songName;
		[saveNewSongView fillInViewValues];
		[self.view addSubview:saveNewSongView];
	}
	
	if (recordingScreenView != nil) 
	{
		[recordingScreenView removeFromSuperview];
		recordingScreenView = nil;
	}
}

-(void) didReplaceSongInRecording
{
	// Song has not been opened yet. There is no song to replace version.
	if(mainDelegate.songID == -1)
	{
		[self didShowSaveNewSongInRecording];
	}
	else 
	{
		replaceSong = [[ReplaceSong alloc] init];
		replaceSong.updatedTracks = mainDelegate.trackObjectArray;
		replaceSong.songID = mainDelegate.songID;
        replaceSong.loopLength = mainDelegate.loopLength;
        replaceSong.tempo = mainDelegate.tempo;
        
        [replaceSong update];	
	}
}

-(void) didScrollTrackInstrument:(NSNotification *) note
{
	NSDictionary *recordingDict = [note object];
	mainDelegate.trackObjectArray = [recordingDict objectForKey:@"trackObjectArray"];
	mainDelegate.recordingTrackNumber = [[recordingDict objectForKey:@"currTrackNumber"] intValue];
}

-(void) didChangeTrackNumber:(NSNotification *)note
{
	mainDelegate.recordingTrackNumber = [[note object] intValue];
}


-(void) didMoveRecordingTimeSlider:(NSNotification *) note
{
	NSDictionary *timeDict = [note object];
	mainDelegate.recordingElapsedMin = [[timeDict objectForKey:@"elapsedMin"] intValue];
	mainDelegate.recordingElapsedSec = [[timeDict objectForKey:@"elapsedSec"] intValue];
}

-(void) didUpdateTrack:(NSNotification *) note
{
	NSDictionary *trackDict = [note object];
	TrackObject *aTrackObject = [trackDict objectForKey:@"trackObject"];
	[mainDelegate.trackObjectArray replaceObjectAtIndex:[[trackDict objectForKey:@"trackNumber"] intValue] withObject:aTrackObject];
}

-(void) didDisableRecordingTabBar
{
	self.tabBarItem.enabled = NO;
}

-(void) didEnableRecordingTabBar
{
	self.tabBarItem.enabled = YES;	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
    
  
    
    CFStringRef route;
    UInt32 propertySize = sizeof(CFStringRef);
    
    
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, &route);
    
    if((route == NULL) || (CFStringGetLength(route) == 0)){
        // Silent Mode
        NSLog(@"AudioRoute: SILENT");
    } else {
        NSString* routeStr = (NSString*)route;
        NSLog(@"AudioRoute: %@", routeStr);
        
        /* Known values of route:
         * "Headset"
         * "Headphone"
         * "Speaker"
         * "SpeakerAndMicrophone"
         * "HeadphonesAndMicrophone"
         * "HeadsetInOut"
         * "ReceiverAndMicrophone"
         * "Lineout"
         */
        
        NSRange headphoneRange = [routeStr rangeOfString : @"Headphone"];
        NSRange headsetRange = [routeStr rangeOfString : @"Headset"];
        NSRange receiverRange = [routeStr rangeOfString : @"Receiver"];
        NSRange speakerRange = [routeStr rangeOfString : @"Speaker"];
        NSRange lineoutRange = [routeStr rangeOfString : @"Lineout"];
        
        if (headphoneRange.location != NSNotFound) {
            // Don't change the route if the headphone is plugged in.
        } else if(headsetRange.location != NSNotFound) {
            // Don't change the route if the headset is plugged in.
        } else if (receiverRange.location != NSNotFound) {
            // Change to play on the speaker
            UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
            AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
        } else if (speakerRange.location != NSNotFound) {
            // Don't change the route if the speaker is currently playing.
        } else if (lineoutRange.location != NSNotFound) {
            // Don't change the route if the lineout is plugged in.
        } else {
            NSLog(@"Unknown audio route.");
        }
    }
}



-(void) viewWillAppear:(BOOL)animated
{
	// Recording Screen will be the default view
	[self didSelectRecordingScreen];
}

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
	
	[recordingScreenView release];
	[saveNewSongView release];
	[replaceSong release];
	
	[nc removeObserver:self name:@"didSelectRecordingScreen" object:nil]; 
	[nc removeObserver:self name:@"didSelectClearSong" object:nil]; 
	[nc removeObserver:self name:@"didShowSaveNewSongInRecording" object:nil]; 
	[nc removeObserver:self name:@"didReplaceSongInRecording" object:nil]; 

	[nc removeObserver:self name:@"didScrollTrackInstrument" object:nil]; 
	[nc removeObserver:self name:@"didChangeTrackNumber" object:nil]; 
	[nc removeObserver:self name:@"didMoveRecordingTimeSlider" object:nil]; 
	[nc removeObserver:self name:@"didUpdateTrack" object:nil]; 
	
	[nc removeObserver:self name:@"didDisableRecordingTabBar" object:nil]; 
	[nc removeObserver:self name:@"didEnableRecordingTabBar" object:nil]; 
}

@end
