//
//  SolocasterDataSource.h
//  Solocaster
//
//  Created by Nikki Fernandez on 11/25/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TrackObject.h"
#import "SongDBDataObject.h"
#import <sqlite3.h>

@interface SolocasterDataSource : NSObject 
{
	NSMutableArray *songs;
	NSMutableArray *tracks;

	int lastSongID;
	int lastTrackID;
}

@property (nonatomic, retain) NSMutableArray *songs;
@property (nonatomic, retain) NSMutableArray *tracks;
@property (nonatomic, assign) int lastSongID;

// Database Path
- (void)copyDatabaseIfNeeded;
- (NSString *)getDBPath;

// Load Functions
- (void)loadSongs;
- (void) loadTracksForSongWithSongID:(int) songID;
-(void) addTrackObject:(int) trackID;

// Insert Functions
- (void) insertSongWithSongName:(NSString *)songName withLoopLength:(int) loopLength withTempo:(int) tempo;
- (void) insertTrack:(TrackObject *)track;
- (int) getLastSongID;
- (int) getLastTrackID;

// Update Functions
- (void) updateSongWithSongID:(int) songID toTracks:(NSMutableArray *)trackObjectArray toLoopLength:(int) loopLength toTempo:(int) tempo;
- (void) updateTracksWithSongID:(int) songID toTracks:(NSMutableArray *)trackObjectArray;
- (void) updateTrackWithTrackID:(int) trackID toTrack:(TrackObject *)track;

// Delete Functions
- (void)deleteSongWithSongID:(int) songID;
- (void) deleteTracksWithSongID:(int) songID;
- (void) deleteTrackWithTrackID:(int) trackID;

@end