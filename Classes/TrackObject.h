//
//  TrackObject.h
//  Solocaster
//
//  Created by Nikki Fernandez on 11/5/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface TrackObject : NSObject 
{
	int trackID;
	int instrument;
	float volumeLevel;
	float pitchLevel;

	BOOL isRecorded;
	BOOL isCurrentTrack;
	BOOL isPlaying;
	
    AVAudioPlayer *player;
	NSMutableString *recordFlags;	// Will store 0 or 1 to mark recorded timings
	NSMutableArray *drumPadArray;   // Will store instrument drum pad indices if a drum track
    
    int recordedItems;
    int playedFlags;
    NSMutableArray *recordedMicArray;
    
    NSString *trackSoundFile;
    
}

@property (nonatomic, assign) int trackID;
@property (nonatomic, assign) int instrument;
@property (nonatomic, assign) float volumeLevel;
@property (nonatomic, assign) float pitchLevel;

@property (nonatomic, assign) BOOL isRecorded;
@property (nonatomic, assign) BOOL isCurrentTrack;
@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, retain) AVAudioPlayer *player;
@property (nonatomic, retain) NSMutableString *recordFlags;
@property (nonatomic, retain) NSMutableArray *drumPadArray;

@property (nonatomic, assign) int recordedItems;
@property (nonatomic, retain) NSMutableArray *recordedMicArray;
@property (nonatomic, assign) int playedFlags;

@property (nonatomic, retain) NSString *trackSoundFile;

@end