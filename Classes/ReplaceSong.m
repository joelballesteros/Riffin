//
//  ReplaceSong.m
//  Solocaster
//
//  Created by Nikki Fernandez on 11/30/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import "ReplaceSong.h"
#import "TrackObject.h"

@implementation ReplaceSong

@synthesize updatedTracks;
@synthesize songID;
@synthesize loopLength;
@synthesize tempo;

- (id) init
{
	if ((self = [super init])) 
	{
		dataSource = [[SolocasterDataSource alloc] init];
	}
	return self;
}

-(void) update
{
	// Replace tracks in song
    [dataSource updateSongWithSongID:songID toTracks:updatedTracks toLoopLength:loopLength toTempo:tempo];
}

- (void)dealloc 
{
	[super dealloc];
	[dataSource release];
}

@end
