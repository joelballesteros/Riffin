//
//  SongViewController.m
//  Solocaster
//
//  Created by Nikki Fernandez on 12/9/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import "SongViewController.h"


@implementation SongViewController

-(id) init
{
	if ((self = [super init]))
	{
		[self initializeNotification];
		mainDelegate = (SolocasterAppDelegate *)[[UIApplication sharedApplication] delegate];
		
		// Show song view
		songView = [[SongView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 460.0f)];
		songView.instrumentArray = mainDelegate.instrumentArray;
		songView.drumKitArray = mainDelegate.drumKitArray;
		songView.songList = mainDelegate.songListArray;
		[songView fillInViewValues];
		[self.view addSubview:songView];
	}
	return self;
}

-(void) initializeNotification
{
	nc = [NSNotificationCenter defaultCenter];
	
	[nc addObserver:self 
		   selector:@selector(reloadSongList) 
			   name:@"reloadSongList" 
			 object:nil];
	
	[nc addObserver:self 
		   selector:@selector(didRearrangeSongs:) 
			   name:@"didRearrangeSongs" 
			 object:nil];
	
	[nc addObserver:self 
		   selector:@selector(didLoadSongs:) 
			   name:@"didLoadSongs" 
			 object:nil];
	
	[nc addObserver:self 
		   selector:@selector(didDisableSongsTabBar) 
			   name:@"didDisableSongsTabBar" 
			 object:nil];
	
	[nc addObserver:self 
		   selector:@selector(didEnableSongsTabBar) 
			   name:@"didEnableSongsTabBar" 
			 object:nil];
}

-(void) reloadSongList
{
	[songView reloadList];
}

-(void) didRearrangeSongs:(NSNotification *) note
{
	mainDelegate.songListArray = [note object];
}

-(void) didLoadSongs:(NSNotification *) note
{
	mainDelegate.songListArray = [note object];
}

-(void) didDisableSongsTabBar
{
	self.tabBarItem.enabled = NO;
}

-(void) didEnableSongsTabBar
{
	self.tabBarItem.enabled = YES;	
}

- (void)didReceiveMemoryWarning {
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
	[songView release];
	
	[nc removeObserver:self name:@"reloadSongList" object:nil];
	[nc removeObserver:self name:@"didRearrangeSongs" object:nil];
	[nc removeObserver:self name:@"didDisableSongsTabBar" object:nil];
	[nc removeObserver:self name:@"didEnableSongsTabBar" object:nil];
}


@end
