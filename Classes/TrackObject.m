//
//  TrackObject.m
//  Solocaster
//
//  Created by Nikki Fernandez on 11/5/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import "TrackObject.h"


@implementation TrackObject

@synthesize trackID;
@synthesize instrument;
@synthesize volumeLevel;
@synthesize pitchLevel;
@synthesize isRecorded;
@synthesize isCurrentTrack;
@synthesize isPlaying;
@synthesize player;
@synthesize recordFlags;
@synthesize recordedItems;
@synthesize recordedMicArray;
@synthesize playedFlags;
@synthesize trackSoundFile;

@synthesize drumPadArray;

-(id) init
{
	if ((self = [super init]))
	{
		recordedMicArray = [[NSMutableArray alloc] init];
        drumPadArray = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc 
{
    [super dealloc];
}

@end
