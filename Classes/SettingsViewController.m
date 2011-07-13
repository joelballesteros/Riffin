//
//  SettingsViewController.m
//  Solocaster
//
//  Created by Nikki Fernandez on 11/3/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import "SettingsViewController.h"
#import "SolocasterAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "UICustomTabBarItem.h"

@implementation SettingsViewController

-(id) init
{
	if ((self = [super init]))
	{
		[self initializeNotification];
		mainDelegate = (SolocasterAppDelegate *)[[UIApplication sharedApplication] delegate];		
		[self didGoBackToSettings];
	}
	return self;
}

-(void) initializeNotification
{
	nc = [NSNotificationCenter defaultCenter];

	[nc addObserver:self 
		   selector:@selector(didGoBackToSettings) 
			   name:@"didGoBackToSettings" 
			 object:nil];
		
	[nc addObserver:self 
		   selector:@selector(didShowAbout) 
			   name:@"didShowAbout" 
			 object:nil];
	
	[nc addObserver:self 
		   selector:@selector(didSwitchRecordBeatSettings:) 
			   name:@"didSwitchRecordBeatSettings" 
			 object:nil];
	
	[nc addObserver:self 
		   selector:@selector(didSwitchRecordInstrumentSettings:) 
			   name:@"didSwitchRecordInstrumentSettings" 
			 object:nil];
	
	[nc addObserver:self 
		   selector:@selector(didDisableSettingsTabBar) 
			   name:@"didDisableSettingsTabBar" 
			 object:nil];
	
	[nc addObserver:self 
		   selector:@selector(didEnableSettingsTabBar) 
			   name:@"didEnableSettingsTabBar" 
			 object:nil];	
}

-(void) didGoBackToSettings
{
	if(settingsView == nil)
	{
		settingsView = [[SettingsView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 460.0f)];
		[self.view addSubview:settingsView];
	}
	settingsView.isRecordBeat = mainDelegate.isRecordBeat;
	settingsView.isRecordInstrument = mainDelegate.isRecordInstrument;
	[settingsView fillInViewValues];
	
	if(aboutView != nil)
	{
		[aboutView removeFromSuperview];
		aboutView = nil;
	}
}

-(void) didShowAbout
{
	if(aboutView == nil)
	{
		aboutView = [[AboutView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 460.0f)];
		[self.view addSubview:aboutView];
	}
	
	if(settingsView != nil)
	{
		[settingsView removeFromSuperview];
		settingsView = nil;
	}
}

-(void) didSwitchRecordBeatSettings:(NSNotification *) note
{
	mainDelegate.isRecordBeat = [[note object] boolValue];
}

-(void) didSwitchRecordInstrumentSettings:(NSNotification *) note
{
	mainDelegate.isRecordInstrument = [[note object] boolValue];
}

-(void) didDisableSettingsTabBar
{
	self.tabBarItem.enabled = NO;
}

-(void) didEnableSettingsTabBar
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
	[settingsView release];
	[aboutView release];

	[nc removeObserver:self name:@"didShowAbout" object:nil]; 
	[nc removeObserver:self name:@"didGoBackToSettings" object:nil]; 

	[nc removeObserver:self name:@"didSwitchRecordBeatSettings" object:nil]; 
	[nc removeObserver:self name:@"didSwitchRecordInstrumentSettings" object:nil]; 
	[nc removeObserver:self name:@"didDisableSettingsTabBar" object:nil]; 
	[nc removeObserver:self name:@"didEnableSettingsTabBar" object:nil]; 	
}


@end
