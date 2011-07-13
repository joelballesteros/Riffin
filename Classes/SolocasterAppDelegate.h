//
//  SolocasterAppDelegate.h
//  Solocaster
//
//  Created by Nikki Fernandez on 11/2/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class SolocasterViewController;

@interface SolocasterAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> 
{
    UIWindow *window;
    SolocasterViewController *viewController;
	
	// Song
	int songID;
	NSString *songName;
	NSMutableArray *songListArray;
	
	// Data Array
	NSMutableArray *trackObjectArray;
    NSMutableArray *trackNumberArray;
	NSMutableArray *instrumentArray;
	NSMutableArray *drumKitArray;
	
	// App Settings
	int tempo;
    int loopLength;
	int recordingTrackNumber;
    
    // Metronome Settings
	BOOL isRecordBeat;
	BOOL isRecordInstrument;
    	
	// Elpased Min and Sec
	int volumeElapsedMin;
	int volumeElapsedSec;
	int pitchElapsedMin;
	int pitchElapsedSec;
	int recordingElapsedMin;
	int recordingElapsedSec;
	int newBeatElapsedMin;
	int newBeatElapsedSec;
    
    // Maximum duration of a song in seconds
    int songDurationMax;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet SolocasterViewController *viewController;

@property (nonatomic, assign) int songID;
@property (nonatomic, retain) NSString *songName;
@property (nonatomic, retain) NSMutableArray *songListArray;

@property (nonatomic, retain) NSMutableArray *trackObjectArray;
@property (nonatomic, retain) NSMutableArray *trackNumberArray;
@property (nonatomic, retain) NSMutableArray *instrumentArray;
@property (nonatomic, retain) NSMutableArray *drumKitArray;

@property (nonatomic, assign) int tempo;
@property (nonatomic, assign) int loopLength;
@property (nonatomic, assign) int recordingTrackNumber;
@property (nonatomic, assign) BOOL isRecordBeat;
@property (nonatomic, assign) BOOL isRecordInstrument;

@property (nonatomic, assign) int volumeElapsedMin;
@property (nonatomic, assign) int volumeElapsedSec;
@property (nonatomic, assign) int pitchElapsedMin;
@property (nonatomic, assign) int pitchElapsedSec;
@property (nonatomic, assign) int recordingElapsedMin;
@property (nonatomic, assign) int recordingElapsedSec;
@property (nonatomic, assign) int newBeatElapsedMin;
@property (nonatomic, assign) int newBeatElapsedSec;

@property (nonatomic, assign) int songDurationMax;

@end

