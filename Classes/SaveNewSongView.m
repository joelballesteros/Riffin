//
//  SaveNewSong.m
//  Solocaster
//
//  Created by Nikki Fernandez on 11/15/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import "SaveNewSongView.h"
#import <QuartzCore/QuartzCore.h>
#import "TrackObject.h"
#import "SongDBDataObject.h"

@implementation SaveNewSongView

@synthesize songName;
@synthesize trackObjectArray;
@synthesize loopLength;
@synthesize tempo;

- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) 
	{
        self.backgroundColor = [UIColor colorWithRed:0.2706f green:0.2706f blue:0.2706f alpha:1.0f];
		nc = [NSNotificationCenter defaultCenter];
		
		// SET GRADIENT COLOR FOR BUTTONS
		CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
		UIColor *highColor = [UIColor colorWithRed:0.2941f green:0.2941f blue:0.2941f alpha:1.0f];
		UIColor *lowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
		[gradientLayer setColors: [NSArray arrayWithObjects:
								   (id)[highColor CGColor], 
								   (id)[lowColor CGColor], nil]];
		
		// SETUP CANCEL BUTTON
		UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cancelButton.frame = CGRectMake(10.0f, 10.0f, 50.0f, 30.0f);
		[gradientLayer setBounds:[cancelButton bounds]];
		[gradientLayer setPosition:CGPointMake([cancelButton bounds].size.width/2,
											   [cancelButton bounds].size.height/2)];
		[[cancelButton layer] insertSublayer:gradientLayer atIndex:0];
		[[cancelButton layer] setCornerRadius:5.0f];
		[[cancelButton layer] setMasksToBounds:YES];
		[[cancelButton layer] setBorderWidth:1.0f];		
		[cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
		cancelButton.titleLabel.font = [UIFont fontWithName:@"Arial" size:12.0f];
		[cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[cancelButton addTarget:self action:@selector(tappedCancelButton:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:cancelButton];
		
		 // SETUP SONG NAME TEXT FIELD
		songNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, 60.0f, 300.0f, 25.0f)];
		songNameTextField.delegate = self;
		songNameTextField.textColor = [UIColor colorWithRed:0.6196f green:0.6196f blue:0.6196f alpha:1.0f];
		songNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		songNameTextField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
		songNameTextField.backgroundColor = [UIColor whiteColor];
		songNameTextField.layer.borderColor = [UIColor blackColor].CGColor;
		songNameTextField.layer.borderWidth = 1.0f;
		songNameTextField.font = [UIFont fontWithName:@"Trebuchet MS" size:15.0f];
		songNameTextField.returnKeyType = UIReturnKeyDone;
		songNameTextField.keyboardAppearance = UIKeyboardAppearanceAlert;
		[self addSubview:songNameTextField];
		
		dataSource = [[SolocasterDataSource alloc] init];
		[gradientLayer release];
    }
    return self;
}

-(void) fillInViewValues
{
	songNameTextField.text = [NSString stringWithFormat:@"%@-2", songName];
}

-(void) tappedCancelButton:(id) sender
{
	[songNameTextField resignFirstResponder];
	[nc postNotificationName:@"didCancelSaveNewSong" object:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];	
	songName = songNameTextField.text;
	[self saveNewSong];

	return YES;
}

-(void) saveNewSong
{
    // Insert track
	for(int i = 0; i < [trackObjectArray count]; i++)
		[dataSource insertTrack:[trackObjectArray objectAtIndex:i]];

	// Insert song
    [dataSource insertSongWithSongName:songName withLoopLength:loopLength withTempo:tempo];
	
	// Set new Song Name and song ID to delegate variables
	NSDictionary *songDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithInt:dataSource.lastSongID], @"songID",
							  songName, @"songName",
							  nil];
	[nc postNotificationName:@"didSaveNewSong" object:songDict];
}

- (void)dealloc 
{
    [super dealloc];
	[songNameTextField release];
	[dataSource release];
}


@end
