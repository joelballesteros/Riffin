//
//  SongDBDataObject.m
//  Solocaster
//
//  Created by Nikki Fernandez on 11/25/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import "SongDBDataObject.h"


@implementation SongDBDataObject

@synthesize songID;
@synthesize songName;
@synthesize track1ID;
@synthesize track2ID;
@synthesize track3ID;
@synthesize track4ID;

@synthesize loopLength;
@synthesize tempo;

@synthesize dateCreated;
@synthesize dateUpdated;

- (void)dealloc 
{
    [super dealloc];
	[songName release];
}

@end
