//
//  SongDBDataObject.h
//  Solocaster
//
//  Created by Nikki Fernandez on 11/25/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SongDBDataObject : NSObject 
{
	int songID;
	NSString *songName;
	int track1ID;
	int track2ID;
	int track3ID;
	int track4ID;
    
    int loopLength;
    int tempo;
    
    NSDate *dateCreated;
	NSDate *dateUpdated;
}

@property (nonatomic, assign) int songID;
@property (nonatomic, retain) NSString *songName;
@property (nonatomic, assign) int track1ID;
@property (nonatomic, assign) int track2ID;
@property (nonatomic, assign) int track3ID;
@property (nonatomic, assign) int track4ID;

@property (nonatomic, assign) int loopLength;
@property (nonatomic, assign) int tempo;

@property (nonatomic, retain) NSDate *dateCreated;
@property (nonatomic, retain) NSDate *dateUpdated;

@end
