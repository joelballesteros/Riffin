//
//  SolocasterViewController.m
//  Solocaster
//
//  Created by Nikki Fernandez on 11/2/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import "SolocasterViewController.h"
#import "TrackObject.h"
#import "InstrumentObject.h"

#define TRACK_COUNT 4
#define DURATION_MAX 270

// Color Macro
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@implementation SolocasterViewController

@synthesize recordingViewController;
@synthesize recordingNewBeatViewController;
@synthesize trackViewController;
@synthesize songViewController;
@synthesize settingsViewController;
@synthesize tabController;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	mainDelegate = (SolocasterAppDelegate *)[[UIApplication sharedApplication] delegate];
	nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self 
		   selector:@selector(showTabBarController) 
			   name:@"showTabBarController" 
			 object:nil];
	[nc addObserver:self 
		   selector:@selector(hideTabBarController) 
			   name:@"hideTabBarController" 
			 object:nil];

	[nc addObserver:self 
		   selector:@selector(selectMixTabBar) 
			   name:@"selectMixTabBar" 
			 object:nil];
	
	// Initialize Default Settings value
	mainDelegate.songID = -1;
	mainDelegate.songName = @"New Song 1";
	mainDelegate.songListArray = [[NSMutableArray alloc] initWithObjects:nil];
	mainDelegate.tempo = 120;
	mainDelegate.isRecordBeat = YES;
	mainDelegate.isRecordInstrument = YES;
	mainDelegate.loopLength = 4;
	mainDelegate.recordingTrackNumber = 0;
    mainDelegate.songDurationMax = DURATION_MAX;
    
    mainDelegate.volumeElapsedMin = 0;
	mainDelegate.volumeElapsedSec = 0;
	mainDelegate.pitchElapsedMin = 0;
	mainDelegate.pitchElapsedSec = 0;
	mainDelegate.recordingElapsedMin = 0;
	mainDelegate.recordingElapsedSec = 0;
	mainDelegate.newBeatElapsedMin = 0;
	mainDelegate.newBeatElapsedSec = 0;
    
	// Initialize Track Numbers
	mainDelegate.trackNumberArray = [[NSMutableArray alloc] initWithObjects:@"Track 1", @"Track 2", @"Track 3", @"Track 4", nil];
	
	// Initialize Instruments
	mainDelegate.instrumentArray = [[NSMutableArray alloc] initWithObjects:nil];
	InstrumentObject *anInstrumentObject;
	
	// Instrument 0: MIC RECORDING
	anInstrumentObject = [[InstrumentObject alloc] init];
	anInstrumentObject.name = @"USE MIC";
	anInstrumentObject.fileName = @"Mic";
	anInstrumentObject.extensionType = @"";
	anInstrumentObject.description = @"Record from Microphone";
	[mainDelegate.instrumentArray addObject:anInstrumentObject];
	[anInstrumentObject release];	

    // Instrument 1
	anInstrumentObject = [[InstrumentObject alloc] init];
	anInstrumentObject.name = @"Guitar-1";
	anInstrumentObject.fileName = @"SoftGuitar-1";
	anInstrumentObject.extensionType = @"mp3";
	anInstrumentObject.description = @"";
	[mainDelegate.instrumentArray addObject:anInstrumentObject];
	[anInstrumentObject release];   

	// Instrument 2
	anInstrumentObject = [[InstrumentObject alloc] init];
	anInstrumentObject.name = @"Guitar-2";
	anInstrumentObject.fileName = @"Guitar-2";
	anInstrumentObject.extensionType = @"mp3";
	anInstrumentObject.description = @"";
	[mainDelegate.instrumentArray addObject:anInstrumentObject];
	[anInstrumentObject release];	
    
    // Instrument 4
	anInstrumentObject = [[InstrumentObject alloc] init];
	anInstrumentObject.name = @"Guitar-3";
	anInstrumentObject.fileName = @"Guitar-3";
	anInstrumentObject.extensionType = @"mp3";
	anInstrumentObject.description = @"";
	[mainDelegate.instrumentArray addObject:anInstrumentObject];
	[anInstrumentObject release];
    
    // Instrument 4
	anInstrumentObject = [[InstrumentObject alloc] init];
	anInstrumentObject.name = @"Guitar-4";
	anInstrumentObject.fileName = @"Guitar-4";
	anInstrumentObject.extensionType = @"mp3";
	anInstrumentObject.description = @"";
	[mainDelegate.instrumentArray addObject:anInstrumentObject];
	[anInstrumentObject release];

	// Instrument 5
	anInstrumentObject = [[InstrumentObject alloc] init];
	anInstrumentObject.name = @"Beat";
	anInstrumentObject.fileName = @"Beat";
	anInstrumentObject.extensionType = @"mp3";
	anInstrumentObject.description = @"";
	[mainDelegate.instrumentArray addObject:anInstrumentObject];
	[anInstrumentObject release];	
    
    // Instrument 5
	anInstrumentObject = [[InstrumentObject alloc] init];
	anInstrumentObject.name = @"Piano-1";
	anInstrumentObject.fileName = @"Piano1";
	anInstrumentObject.extensionType = @"mp3";
	anInstrumentObject.description = @"";
	[mainDelegate.instrumentArray addObject:anInstrumentObject];
	[anInstrumentObject release];
    
	// Instrument 5
	anInstrumentObject = [[InstrumentObject alloc] init];
	anInstrumentObject.name = @"Drums-1";
	anInstrumentObject.fileName = @"Drums1";
	anInstrumentObject.extensionType = @"mp3";
	anInstrumentObject.description = @"";
	[mainDelegate.instrumentArray addObject:anInstrumentObject];
	[anInstrumentObject release];
	
    // Instrument 5
	anInstrumentObject = [[InstrumentObject alloc] init];
	anInstrumentObject.name = @"Drums-2";
	anInstrumentObject.fileName = @"Drums2";
	anInstrumentObject.extensionType = @"mp3";
	anInstrumentObject.description = @"";
	[mainDelegate.instrumentArray addObject:anInstrumentObject];
	[anInstrumentObject release];

    // Instrument 5
	anInstrumentObject = [[InstrumentObject alloc] init];
	anInstrumentObject.name = @"Drums-3";
	anInstrumentObject.fileName = @"Drums3";
	anInstrumentObject.extensionType = @"mp3";
	anInstrumentObject.description = @"";
	[mainDelegate.instrumentArray addObject:anInstrumentObject];
	[anInstrumentObject release];
    
    // Instrument 5
	anInstrumentObject = [[InstrumentObject alloc] init];
	anInstrumentObject.name = @"Drums-4";
	anInstrumentObject.fileName = @"Drums4";
	anInstrumentObject.extensionType = @"mp3";
	anInstrumentObject.description = @"";
	[mainDelegate.instrumentArray addObject:anInstrumentObject];
	[anInstrumentObject release];
    
	// Instrument 5: CUSTOM BEAT
	anInstrumentObject = [[InstrumentObject alloc] init];
	anInstrumentObject.name = @"CUSTOM BEAT";
	anInstrumentObject.fileName = @"none";
	anInstrumentObject.extensionType = @"none";
	anInstrumentObject.description = @"Double-click to create drum beat";
	[mainDelegate.instrumentArray addObject:anInstrumentObject];
	[anInstrumentObject release];	
	
	// Initialize Drum Kit
	mainDelegate.drumKitArray = [[NSMutableArray alloc] initWithObjects:nil];
	
	// Instrument 1: BASS DRUM
	anInstrumentObject = [[InstrumentObject alloc] init];
	anInstrumentObject.name = @"BASS DRUM";
	anInstrumentObject.fileName = @"BassDrum";
	anInstrumentObject.extensionType = @"m4a";
	anInstrumentObject.description = @"";
	[mainDelegate.drumKitArray addObject:anInstrumentObject];
	[anInstrumentObject release];		
	// Instrument 2: SNARE
	anInstrumentObject = [[InstrumentObject alloc] init];
	anInstrumentObject.name = @"SNARE";
	anInstrumentObject.fileName = @"Snare";
	anInstrumentObject.extensionType = @"m4a";
	anInstrumentObject.description = @"";
	[mainDelegate.drumKitArray addObject:anInstrumentObject];
	[anInstrumentObject release];
	// Instrument 3: CRASH CYMBOL
	anInstrumentObject = [[InstrumentObject alloc] init];
	anInstrumentObject.name = @"CRASH CYMBOL";
	anInstrumentObject.fileName = @"CrashCymbol";
	anInstrumentObject.extensionType = @"m4a";
	anInstrumentObject.description = @"";
	[mainDelegate.drumKitArray addObject:anInstrumentObject];
	[anInstrumentObject release];
	// Instrument 4: HIGH HAT HALF
	anInstrumentObject = [[InstrumentObject alloc] init];
	anInstrumentObject.name = @"HALF HH";
	anInstrumentObject.fileName = @"HighHatHalf";
	anInstrumentObject.extensionType = @"m4a";
	anInstrumentObject.description = @"";
	[mainDelegate.drumKitArray addObject:anInstrumentObject];
	[anInstrumentObject release];
	// Instrument 5: LOW TOM
	anInstrumentObject = [[InstrumentObject alloc] init];
	anInstrumentObject.name = @"LOW TOM";
	anInstrumentObject.fileName = @"LowTom";
	anInstrumentObject.extensionType = @"m4a";
	anInstrumentObject.description = @"";
	[mainDelegate.drumKitArray addObject:anInstrumentObject];
	[anInstrumentObject release];
	// Instrument 6: HIGH HAT CLOSED
	anInstrumentObject = [[InstrumentObject alloc] init];
	anInstrumentObject.name = @"CLOSED HH";
	anInstrumentObject.fileName = @"HighHatClosed";
	anInstrumentObject.extensionType = @"m4a";
	anInstrumentObject.description = @"";
	[mainDelegate.drumKitArray addObject:anInstrumentObject];
	[anInstrumentObject release];
	// Instrument 7: RIDE CYMBOL
	anInstrumentObject = [[InstrumentObject alloc] init];
	anInstrumentObject.name = @"RIDE CYMBOL";
	anInstrumentObject.fileName = @"RideCymbol";
	anInstrumentObject.extensionType = @"m4a";
	[mainDelegate.drumKitArray addObject:anInstrumentObject];
	[anInstrumentObject release];	
	// Instrument 8: HIGH TOM
	anInstrumentObject = [[InstrumentObject alloc] init];
	anInstrumentObject.name = @"HI TOM";
	anInstrumentObject.fileName = @"HighTom";
	anInstrumentObject.extensionType = @"m4a";
	anInstrumentObject.description = @"";
	[mainDelegate.drumKitArray addObject:anInstrumentObject];
	[anInstrumentObject release];
	// Instrument 9: SPLASH CYMBOL
	anInstrumentObject = [[InstrumentObject alloc] init];
	anInstrumentObject.name = @"SPLASH CYMBOL";
	anInstrumentObject.fileName = @"SplashCymbol";
	anInstrumentObject.extensionType = @"m4a";
	anInstrumentObject.description = @"";
	[mainDelegate.drumKitArray addObject:anInstrumentObject];
	[anInstrumentObject release];
	// Instrument 10: NO BEAT
	anInstrumentObject = [[InstrumentObject alloc] init];
	anInstrumentObject.name = @"NO BEAT";
	anInstrumentObject.fileName = @"none";
	anInstrumentObject.extensionType = @"none";
	anInstrumentObject.description = @"";
	[mainDelegate.drumKitArray addObject:anInstrumentObject];
	[anInstrumentObject release];
	
	// Initialize Track Object Array
	int i;
	TrackObject *aTrackObject;
	mainDelegate.trackObjectArray = [[NSMutableArray alloc] initWithObjects:nil];
	for(i = 0; i < TRACK_COUNT; ++i)
	{
		aTrackObject = [[TrackObject alloc] init];
		aTrackObject.trackID = -1;
		aTrackObject.instrument = 0;
		aTrackObject.volumeLevel = 0.0f;
		aTrackObject.pitchLevel = 0.0f;
		aTrackObject.isRecorded = NO;
		aTrackObject.isCurrentTrack = NO;
		aTrackObject.player = nil;
		
		// Initialize recordFlags to all '0' to indicate no recording
		char repeatString[DURATION_MAX + 1];
		memset(repeatString, '0', DURATION_MAX);
		repeatString[DURATION_MAX] = 0;
		aTrackObject.recordFlags = [NSMutableString stringWithCString:repeatString encoding: NSUTF8StringEncoding];
        aTrackObject.drumPadArray = [[NSMutableArray alloc] initWithObjects:nil];
		
		if(i == 0)
			aTrackObject.isCurrentTrack = YES;
		
		[mainDelegate.trackObjectArray addObject:aTrackObject];
		[aTrackObject release];
	}
	
	//-------------------------------------------------------------------
	localControllersArray = [[NSMutableArray alloc] initWithCapacity:4];	
	
	// SETUP Recording
	recordingViewController = [[RecordingViewController alloc] init];
	[localControllersArray addObject:recordingViewController];	
	
	// INITIALIZE Recording New Beat
	recordingNewBeatViewController = [[RecordingNewBeatViewController alloc] init];
	
	// SETUP Tracks
	trackViewController = [[TrackViewController alloc] init];
	[localControllersArray addObject:trackViewController];
	
	// SETUP Songs
	songViewController = [[SongViewController alloc] init];
	[localControllersArray addObject:songViewController];

	// SETUP Settings
	settingsViewController = [[SettingsViewController alloc] init];
	[localControllersArray addObject:settingsViewController];

	// SETUP Tab Controller
	tabController = [[UITabBarController alloc] init];
	tabController.view.frame = CGRectMake(0.0f, 0.0f, 320.0f, 460.0f);
	tabController.delegate = self;
	[tabController setViewControllers:localControllersArray];

	//------------------------------------------------------------
	// CUSTOMIZE TAB BARS
	
	float tabWidth = tabController.tabBar.bounds.size.width / [localControllersArray count];
	float tabHeight = 49.0f;
	float xpos = 0.0f;
	tabSelectedIndex = 0;
	
	// RECORD TAB
	recordView = [[UIImageView alloc] initWithFrame:CGRectMake(xpos, 0.0f, tabWidth, tabHeight)];
	recordView.image = [UIImage imageNamed:@"record-tab.png"];
	[[tabController tabBar] addSubview:recordView];
	
	recordLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, recordView.bounds.size.height - 11.0f, recordView.bounds.size.width, 8.0f)];
	recordLabel.backgroundColor = [UIColor clearColor];
	recordLabel.font = [UIFont fontWithName:@"GrixelAcme5WideXtnd" size:8.0f];
	recordLabel.textAlignment = UITextAlignmentCenter;
	recordLabel.text = @"RECORD";
	recordLabel.textColor = RGBA(80, 80, 80, 1);
	[recordView addSubview:recordLabel];
	xpos += tabWidth;
	
	// MIX TAB
	mixView = [[UIImageView alloc] initWithFrame:CGRectMake(xpos, 0.0f, tabWidth, tabHeight)];
	mixView.image = [UIImage imageNamed:@"mix-tab.png"];
	[[tabController tabBar] addSubview:mixView];
	
	mixLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, mixView.bounds.size.height - 11.0f, mixView.bounds.size.width, 8.0f)];
	mixLabel.backgroundColor = [UIColor clearColor];
	mixLabel.font = [UIFont fontWithName:@"GrixelAcme5WideXtnd" size:8.0f];
	mixLabel.textAlignment = UITextAlignmentCenter;
	mixLabel.text = @"MIX";
	mixLabel.textColor = RGBA(80, 80, 80, 1);
	[mixView addSubview:mixLabel];
	xpos += tabWidth;
	
	// SONGS TAB
	songsView = [[UIImageView alloc] initWithFrame:CGRectMake(xpos, 0.0f, tabWidth, tabHeight)];
	songsView.image = [UIImage imageNamed:@"songs-tab.png"];
	[[tabController tabBar] addSubview:songsView];
	
	songsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, songsView.bounds.size.height - 11.0f, songsView.bounds.size.width, 8.0f)];
	songsLabel.backgroundColor = [UIColor clearColor];
	songsLabel.font = [UIFont fontWithName:@"GrixelAcme5WideXtnd" size:8.0f];
	songsLabel.textAlignment = UITextAlignmentCenter;
	songsLabel.text = @"SONGS";
	songsLabel.textColor = RGBA(80, 80, 80, 1);
	[songsView addSubview:songsLabel];
	xpos += tabWidth;
	
	// SETTINGS TAB
	settingsView = [[UIImageView alloc] initWithFrame:CGRectMake(xpos, 0.0f, tabWidth, tabHeight)];
	settingsView.image = [UIImage imageNamed:@"setting-tab.png"];
	[[tabController tabBar] addSubview:settingsView];
	
	settingsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, settingsView.bounds.size.height - 11.0f, settingsView.bounds.size.width, 8.0f)];
	settingsLabel.backgroundColor = [UIColor clearColor];
	settingsLabel.font = [UIFont fontWithName:@"GrixelAcme5WideXtnd" size:8.0f];
	settingsLabel.textAlignment = UITextAlignmentCenter;
	settingsLabel.text = @"SETTINGS";
	settingsLabel.textColor = RGBA(80, 80, 80, 1);
	[settingsView addSubview:settingsLabel];
	[settingsLabel release];

	[self updateTabBarState:0];
	//------------------------------------------------------------	
	
	// SETUP Launch Page
	launchImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]];
	launchImage.frame = CGRectMake(0.0f, 0.0f, 320.0f, 460.0f);
	[self.view addSubview:launchImage];
	
	[self performSelector:@selector(hideLaunchPage) withObject:nil afterDelay:0.2];	
}

-(void) hideLaunchPage
{
	[launchImage removeFromSuperview];
	[self.view addSubview:tabController.view];
	[localControllersArray release];
}

-(void) hideTabBarController
{
	[tabController presentModalViewController:recordingNewBeatViewController animated:NO];
}

-(void) showTabBarController
{
	[tabController dismissModalViewControllerAnimated:NO];	
}

-(void) selectMixTabBar
{
	[self updateTabBarState:1];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
	if(viewController == recordingViewController)
	{
		[recordingViewController didSelectRecordingScreen];
	}
	else if(viewController == trackViewController)
	{	
		if([trackViewController isLastViewVolume] == YES)
			[trackViewController didSelectVolume];	
		else 
			[trackViewController didSelectPitch];
	}
	else if(viewController == songViewController)
	{
		[songViewController reloadSongList];
	}

	[self updateTabBarState:tabBarController.selectedIndex];
}

-(void) updateTabBarState:(int) tabIndex
{
	// Deselect previous
	switch(tabSelectedIndex)
	{
		case 0:
			recordView.image = [UIImage imageNamed:@"record-tab.png"];
			recordLabel.textColor = RGBA(80, 80, 80, 1);
			break;
		case 1:
			mixView.image = [UIImage imageNamed:@"mix-tab.png"];
			mixLabel.textColor = RGBA(80, 80, 80, 1);
			break;
		case 2:
			songsView.image = [UIImage imageNamed:@"songs-tab.png"];
			songsLabel.textColor = RGBA(80, 80, 80, 1);
			break;
		case 3:
			settingsView.image = [UIImage imageNamed:@"setting-tab.png"];
			settingsLabel.textColor = RGBA(80, 80, 80, 1);
			break;
		default:
			break;
	}
	
	// Select current
	switch(tabIndex)
	{
		case 0:
			recordView.image = [UIImage imageNamed:@"record-tab-selected.png"];
			recordLabel.textColor = RGBA(200, 200, 200, 1);
			break;
		case 1:
			mixView.image = [UIImage imageNamed:@"mix-tab-selected.png"];
			mixLabel.textColor = RGBA(200, 200, 200, 1);
			break;
		case 2:
			songsView.image = [UIImage imageNamed:@"songs-tab-selected.png"];
			songsLabel.textColor = RGBA(200, 200, 200, 1);
			break;
		case 3:
			settingsView.image = [UIImage imageNamed:@"settings-tab-selected.png"];
			settingsLabel.textColor = RGBA(200, 200, 200, 1);
			break;
		default:
			break;
	}
	tabSelectedIndex = tabIndex;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc 
{
	[recordingViewController release];
	[recordingNewBeatViewController release];
	[trackViewController release];
	[songViewController release];
	[settingsViewController release];
	
	[launchImage release];
	[tabController release];
	[localControllersArray release];
	
	[recordView release];
	[recordLabel release];
	[mixView release];
	[mixLabel release];
	[songsView release];
	[songsLabel release];
	[settingsView release];
	[settingsLabel release];
	
	[nc removeObserver:self name:@"showTabBarController" object:nil]; 
	[nc removeObserver:self name:@"hideTabBarController" object:nil]; 
	[nc removeObserver:self name:@"selectMixTabBar" object:nil]; 
	
    [super dealloc];
}

@end
