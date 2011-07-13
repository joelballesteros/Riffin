//
//  SolocasterDataSource.m
//  Solocaster
//
//  Created by Nikki Fernandez on 11/25/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import "SolocasterDataSource.h"

@implementation SolocasterDataSource

@synthesize songs;
@synthesize tracks;
@synthesize lastSongID;

- (id) init
{
	if ((self = [super init])) 
	{
		songs = [[NSMutableArray alloc] initWithObjects:nil];
		tracks = [[NSMutableArray alloc] initWithObjects:nil];
		[self copyDatabaseIfNeeded];
	}
	return self;
}

#pragma mark Sqlite access

- (void) copyDatabaseIfNeeded 
{	
	//Using NSFileManager we can perform many file system operations.
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSString *dbPath = [self getDBPath];
	BOOL success = [fileManager fileExistsAtPath:dbPath]; 
	
	if(!success) 
	{	
		NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Solocaster.sqlite"];
		success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
		
		if (!success) 
			NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
	}	
}

- (NSString *) getDBPath
{
	//Search for standard documents using NSSearchPathForDirectoriesInDomains
	//First Param = Searching the documents directory
	//Second Param = Searching the Users directory and not the System
	//Expand any tildes and identify home directories.
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	return [documentsDir stringByAppendingPathComponent:@"Solocaster.sqlite"];
}

//-----------------------------------------------------------------------------------
// LOAD FUNCTIONS
- (void) loadSongs
{
	sqlite3 *db;
	
	if(sqlite3_open([[self getDBPath] UTF8String], &db) == SQLITE_OK)
	{
		const char *sql = "SELECT songID, songName, track1ID, track2ID, track3ID, track4ID, loopLength, tempo FROM Song";
		sqlite3_stmt *stmt;
		
		if(sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK) 
		{
			SongDBDataObject *aSong;
			while(sqlite3_step(stmt) == SQLITE_ROW) 
			{	
				aSong = [[SongDBDataObject alloc] init];
				
				// SONG ID
				char *songIDChars = (char *)sqlite3_column_text(stmt, 0);
				if(songIDChars == NULL)
				{
					aSong.songID = -1;
				}
				else 
				{
					aSong.songID = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)] intValue];
				}
				
				// SONG NAME
				char *songNameChars = (char *)sqlite3_column_text(stmt, 1);
				if(songNameChars == NULL)
				{
					aSong.songName = [NSString stringWithString:@""];
				}
				else 
				{
					aSong.songName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 1)];	
				}
				
				// TRACK 1 ID
				char *track1IDChars = (char *)sqlite3_column_text(stmt, 2);
				if(track1IDChars == NULL)
				{
					aSong.track1ID = -1;
				}
				else 
				{
					aSong.track1ID = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)] intValue];	
				}
				
				// TRACK 2 ID
				char *track2IDChars = (char *)sqlite3_column_text(stmt, 3);
				if(track2IDChars == NULL)
				{
					aSong.track2ID = -1;
				}
				else 
				{					
					aSong.track2ID = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 3)] intValue];
				}
				
				// TRACK 3 ID
				char *track3IDChars = (char *)sqlite3_column_text(stmt, 4);
				if(track3IDChars == NULL)
				{
					aSong.track3ID = -1;
				}
				else 
				{					
					aSong.track3ID = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 4)] intValue];
				}
				
				// TRACK 4 ID
				char *track4IDChars = (char *)sqlite3_column_text(stmt, 5);
				if(track4IDChars == NULL)
				{
					aSong.track4ID = -1;
				}
				else 
				{					
					aSong.track4ID = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 5)] intValue];
				}
				
                // LOOP LENGTH
				char *loopLengthChars = (char *)sqlite3_column_text(stmt, 6);
				if(loopLengthChars == NULL)
				{
					aSong.loopLength = -1;
				}
				else 
				{					
					aSong.loopLength = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 6)] intValue];
				}
                
                // TEMPO
				char *tempoChars = (char *)sqlite3_column_text(stmt, 7);
				if(tempoChars == NULL)
				{
					aSong.tempo = -1;
				}
				else 
				{					
					aSong.tempo = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 7)] intValue];
				}
                
                [songs addObject:aSong];
				[aSong release];
			}
		}
		sqlite3_finalize(stmt);
	}
	sqlite3_close(db);
}

- (void) loadTracksForSongWithSongID:(int) songID
{
	// Get all trackIDs for the selected song
	int track1ID, track2ID, track3ID, track4ID;
	sqlite3 *db;
	
	if(sqlite3_open([[self getDBPath] UTF8String], &db) == SQLITE_OK)
	{
		const char *sql = "SELECT track1ID, track2ID, track3ID, track4ID FROM Song WHERE songID = ?";
		sqlite3_stmt *stmt;
		
		if(sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK) 
		{
			sqlite3_bind_int(stmt, 1, songID);
			while(sqlite3_step(stmt) == SQLITE_ROW) 
			{
				// TRACK 1 ID
				char *track1IDChars = (char *)sqlite3_column_text(stmt, 0);
				if(track1IDChars == NULL)
				{
					track1ID = -1;
				}
				else 
				{
					track1ID = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)] intValue];	
				}

				// TRACK 2 ID
				char *track2IDChars = (char *)sqlite3_column_text(stmt, 1);
				if(track2IDChars == NULL)
				{
					track2ID = -1;
				}
				else 
				{
					track2ID = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 1)] intValue];
				}
				
				// TRACK 3 ID
				char *track3IDChars = (char *)sqlite3_column_text(stmt, 2);
				if(track3IDChars == NULL)
				{
					track3ID = -1;
				}
				else 
				{
					track3ID = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)] intValue];
				}
				
				// TRACK 4 ID
				char *track4IDChars = (char *)sqlite3_column_text(stmt, 3);
				if(track4IDChars == NULL)
				{
					track4ID = -1;
				}
				else 
				{
					track4ID = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 3)] intValue];
				}
			}
		}
		sqlite3_finalize(stmt);
	}
	sqlite3_close(db);
	
	[tracks removeAllObjects];
	
	//Fill in track object array
	[self addTrackObject:track1ID];
	[self addTrackObject:track2ID];
	[self addTrackObject:track3ID];
	[self addTrackObject:track4ID];
}

-(void) addTrackObject:(int) trackID
{
	sqlite3 *db;
	TrackObject *aTrackObject;
	
	if(sqlite3_open([[self getDBPath] UTF8String], &db) == SQLITE_OK)
	{
		const char *sql = "SELECT instrument, volumeLevel, pitchLevel, isRecorded, isCurrentTrack, recordFlags, drumPad, soundfile FROM Track WHERE trackID = ?";
		sqlite3_stmt *stmt;
		
		if(sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK) 
		{
			sqlite3_bind_int(stmt, 1, trackID);
			while(sqlite3_step(stmt) == SQLITE_ROW) 
			{
				aTrackObject = [[TrackObject alloc] init];
				aTrackObject.instrument = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)] intValue];
				aTrackObject.volumeLevel = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 1)] floatValue];
				aTrackObject.pitchLevel = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)] floatValue];
				aTrackObject.isRecorded = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 3)] intValue];
				aTrackObject.isCurrentTrack = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 4)] intValue];
				aTrackObject.recordFlags = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 5)];
                
                NSString *drumPadString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 6)];
                NSArray *drumPadElements = [drumPadString componentsSeparatedByString:@","];
                aTrackObject.drumPadArray = [[NSMutableArray alloc] initWithArray:drumPadElements];
                
            
                char *soundfile = (char *)sqlite3_column_text(stmt, 7);
                
                if (soundfile == NULL)
                {
                    aTrackObject.trackSoundFile = @"";
                }
                else
                {
                    NSLog(@"song %@", [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 7)]);                    
                    aTrackObject.trackSoundFile = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 7)];
                }
				
				aTrackObject.trackID = trackID;
				aTrackObject.player = nil;
				[tracks addObject:aTrackObject];
				[aTrackObject release];
			}
		}
		sqlite3_finalize(stmt);
	}
	sqlite3_close(db);
}

//-----------------------------------------------------------------------------------
// INSERT FUNCTIONS
- (void) insertSongWithSongName:(NSString *)songName withLoopLength:(int) loopLength withTempo:(int) tempo
{
	// Get the latest trackID added
	lastTrackID = [self getLastTrackID];
	
	sqlite3 *db;
	
	[self copyDatabaseIfNeeded];
	if(sqlite3_open([[self getDBPath] UTF8String], &db) == SQLITE_OK)
	{
		const char *sql = "INSERT INTO Song (songName, track1ID, track2ID, track3ID, track4ID, loopLength, tempo) VALUES (?,?,?,?,?,?,?)";
		sqlite3_stmt *stmt;
		
		if(sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK) 
		{
			sqlite3_bind_text(stmt, 1, [songName UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_int(stmt, 2, lastTrackID - 3);
			sqlite3_bind_int(stmt, 3, lastTrackID - 2);
			sqlite3_bind_int(stmt, 4, lastTrackID - 1);
			sqlite3_bind_int(stmt, 5, lastTrackID);
            sqlite3_bind_int(stmt, 6, loopLength);
            sqlite3_bind_int(stmt, 7, tempo);
			
			if(sqlite3_step(stmt) != SQLITE_DONE)
			{
				NSLog(@"Error inserting song data");
			}
		}
		sqlite3_finalize(stmt);
	}
	sqlite3_close(db);
	
	// Get the latest songID added
	lastSongID = [self getLastSongID];
}

- (void) insertTrack:(TrackObject *)track
{
	sqlite3 *db;
	
	[self copyDatabaseIfNeeded];
	if(sqlite3_open([[self getDBPath] UTF8String], &db) == SQLITE_OK)
	{
		const char *sql = "INSERT INTO Track (instrument, volumeLevel, pitchLevel, isRecorded, isCurrentTrack, recordFlags, drumPad, soundfile) VALUES (?,?,?,?,?,?,?,?)";
		sqlite3_stmt *stmt;
		
		if(sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK) 
		{
			sqlite3_bind_int(stmt, 1, track.instrument);
			sqlite3_bind_double(stmt, 2, track.volumeLevel);
			sqlite3_bind_double(stmt, 3, track.pitchLevel);
			sqlite3_bind_int(stmt, 4, track.isRecorded);
			sqlite3_bind_int(stmt, 5, track.isCurrentTrack);			
			sqlite3_bind_text(stmt, 6, [track.recordFlags UTF8String], -1, SQLITE_TRANSIENT);
            
            // Create drumPad string
            NSMutableString *drumPadString = [[NSMutableString alloc] init];
            for(int i = 0; i < [track.drumPadArray count]; i++)
            {
                [drumPadString appendString:[NSString stringWithFormat:@"%d,", [[track.drumPadArray objectAtIndex:i] intValue]]];
            }
            sqlite3_bind_text(stmt, 7, [drumPadString UTF8String], -1, SQLITE_TRANSIENT);
            
            NSLog(@"saving soundtrack file %@", track.trackSoundFile);
            NSString *respath = [track.trackSoundFile retain];
            
            NSLog(@"saving file %@", [respath lastPathComponent]);
            
			sqlite3_bind_text(stmt, 8, [[respath lastPathComponent] UTF8String], -1, SQLITE_TRANSIENT);
            
			if(sqlite3_step(stmt) != SQLITE_DONE)
			{
				NSLog(@"Error inserting track data");
			}
		}
		sqlite3_finalize(stmt);
	}
	sqlite3_close(db);
}

- (int) getLastSongID
{
	int lastID = -1;
	sqlite3 *db;
	
	if(sqlite3_open([[self getDBPath] UTF8String], &db) == SQLITE_OK)
	{
		const char *sql = "SELECT songID FROM Song ORDER BY songID DESC LIMIT 1";
		sqlite3_stmt *stmt;
		
		if(sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK) 
		{
			while(sqlite3_step(stmt) == SQLITE_ROW) 
			{	
				lastID = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)] intValue];
			}
		}
		sqlite3_finalize(stmt);
	}
	sqlite3_close(db);
	
	return lastID;
}

- (int) getLastTrackID
{
	int lastID = -1;
	sqlite3 *db;
	
	if(sqlite3_open([[self getDBPath] UTF8String], &db) == SQLITE_OK)
	{
		const char *sql = "SELECT trackID FROM Track ORDER BY trackID DESC LIMIT 1";
		sqlite3_stmt *stmt;
		
		if(sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK) 
		{
			while(sqlite3_step(stmt) == SQLITE_ROW) 
			{	
				lastID = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)] intValue];
			}
		}
		sqlite3_finalize(stmt);
	}
	sqlite3_close(db);
	
	return lastID;
}

//-----------------------------------------------------------------------------------
// UPDATE FUNCTIONS
- (void) updateSongWithSongID:(int) songID toTracks:(NSMutableArray *)trackObjectArray toLoopLength:(int) loopLength toTempo:(int) tempo
{
    // Update loop length, tempo, drum Low and drum Hi
    sqlite3 *db;
	[self copyDatabaseIfNeeded];
	if(sqlite3_open([[self getDBPath] UTF8String], &db) == SQLITE_OK)
	{
		const char *sql = "UPDATE Song SET loopLength = ?, tempo = ? WHERE songID = ?";
		sqlite3_stmt *stmt;
		
		if(sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK) 
		{
			sqlite3_bind_int(stmt, 1, loopLength);
			sqlite3_bind_int(stmt, 2, tempo);
            sqlite3_bind_int(stmt, 3, songID);
			
			if (sqlite3_step(stmt) != SQLITE_DONE)
			{
				NSLog(@"Error updating data");
			}
		}
        sqlite3_finalize(stmt);
	}
	sqlite3_close(db);
    
    // Update the tracks in the song
	[self updateTracksWithSongID:songID toTracks:trackObjectArray];
}

- (void) updateTracksWithSongID:(int) songID toTracks:(NSMutableArray *)trackObjectArray
{
	// Get all trackIDs for the selected song
	int track1ID, track2ID, track3ID, track4ID;
	sqlite3 *db;
	
	if(sqlite3_open([[self getDBPath] UTF8String], &db) == SQLITE_OK)
	{
		const char *sql = "SELECT track1ID, track2ID, track3ID, track4ID FROM Song WHERE songID = ?";
		sqlite3_stmt *stmt;
		
		if(sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK) 
		{
			sqlite3_bind_int(stmt, 1, songID);
			while(sqlite3_step(stmt) == SQLITE_ROW) 
			{
				track1ID = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)] intValue];
				track2ID = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 1)] intValue];
				track3ID = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)] intValue];
				track4ID = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 3)] intValue];
			}
		}
		sqlite3_finalize(stmt);
	}
	sqlite3_close(db);

	// Update tracks
	[self updateTrackWithTrackID:track1ID toTrack:[trackObjectArray objectAtIndex:0]];
	[self updateTrackWithTrackID:track2ID toTrack:[trackObjectArray objectAtIndex:1]];
	[self updateTrackWithTrackID:track3ID toTrack:[trackObjectArray objectAtIndex:2]];
	[self updateTrackWithTrackID:track4ID toTrack:[trackObjectArray objectAtIndex:3]];
}

- (void) updateTrackWithTrackID:(int) trackID toTrack:(TrackObject *)track
{
	sqlite3 *db;
	
	[self copyDatabaseIfNeeded];
	if(sqlite3_open([[self getDBPath] UTF8String], &db) == SQLITE_OK)
	{
		const char *sql = "UPDATE Track SET instrument = ?, volumeLevel = ?, pitchLevel = ?, isRecorded = ?, isCurrentTrack = ?, recordFlags = ?, drumPad = ?, soundfile = ? WHERE trackID = ?";
		sqlite3_stmt *stmt;
		
		if(sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK) 
		{
			sqlite3_bind_int(stmt, 1, track.instrument);
			sqlite3_bind_double(stmt, 2, track.volumeLevel);
			sqlite3_bind_double(stmt, 3, track.pitchLevel);
			sqlite3_bind_int(stmt, 4, track.isRecorded);
			sqlite3_bind_int(stmt, 5, track.isCurrentTrack);			
			sqlite3_bind_text(stmt, 6, [track.recordFlags UTF8String], -1, SQLITE_TRANSIENT);
            
            // Create drumPad string
            NSMutableString *drumPadString = [[NSMutableString alloc] init];
            for(int i = 0; i < [track.drumPadArray count]; i++)
            {
                [drumPadString appendString:[NSString stringWithFormat:@"%d,", [[track.drumPadArray objectAtIndex:i] intValue]]];
            }
            sqlite3_bind_text(stmt, 7, [drumPadString UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(stmt, 8, [track.trackSoundFile UTF8String], -1, SQLITE_TRANSIENT);
            
			sqlite3_bind_int(stmt, 9, trackID);
			
			if (sqlite3_step(stmt) != SQLITE_DONE)
			{
				NSLog(@"Error updating data");
			}
		}
		sqlite3_finalize(stmt);
	}
	sqlite3_close(db);
}

//-----------------------------------------------------------------------------------
// DELETE FUNCTIONS
- (void) deleteSongWithSongID:(int) songID
{
	// Delete tracks for the song
	[self deleteTracksWithSongID:songID];
	
	sqlite3 *db;
	
	[self copyDatabaseIfNeeded];
	if(sqlite3_open([[self getDBPath] UTF8String], &db) == SQLITE_OK)
	{
		const char *sql = "DELETE FROM Song WHERE songID = ?";
		sqlite3_stmt *stmt;
		
		if(sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK) 
		{
			sqlite3_bind_int(stmt, 1, songID);
			if (sqlite3_step(stmt) != SQLITE_DONE)
			{
				NSLog(@"Error deleting data");
			}
		}
		sqlite3_finalize(stmt);
	}
	sqlite3_close(db);
}

- (void) deleteTracksWithSongID:(int) songID
{
	// Get all trackIDs for the selected song
	int track1ID, track2ID, track3ID, track4ID;
	sqlite3 *db;
	
	if(sqlite3_open([[self getDBPath] UTF8String], &db) == SQLITE_OK)
	{
		const char *sql = "SELECT track1ID, track2ID, track3ID, track4ID FROM Song WHERE songID = ?";
		sqlite3_stmt *stmt;
		
		if(sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK) 
		{
			sqlite3_bind_int(stmt, 1, songID);
			while(sqlite3_step(stmt) == SQLITE_ROW) 
			{
				track1ID = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)] intValue];
				track2ID = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 1)] intValue];
				track3ID = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)] intValue];
				track4ID = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 3)] intValue];
			}
		}
		sqlite3_finalize(stmt);
	}
	sqlite3_close(db);
	
	// Delete tracks
	[self deleteTrackWithTrackID:track1ID];
	[self deleteTrackWithTrackID:track2ID];
	[self deleteTrackWithTrackID:track3ID];
	[self deleteTrackWithTrackID:track4ID];	
}

- (void) deleteTrackWithTrackID:(int) trackID
{
	sqlite3 *db;
	
	[self copyDatabaseIfNeeded];
	if(sqlite3_open([[self getDBPath] UTF8String], &db) == SQLITE_OK)
	{
		const char *sql = "DELETE FROM Track WHERE trackID = ?";
		sqlite3_stmt *stmt;
		
		if(sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK) 
		{
			sqlite3_bind_int(stmt, 1, trackID);
			if (sqlite3_step(stmt) != SQLITE_DONE)
			{
				NSLog(@"Error deleting data");
			}
		}
		sqlite3_finalize(stmt);
	}
	sqlite3_close(db);
}

//-----------------------------------------------------------------------------------
- (void) dealloc
{
	[songs release];
	[tracks release];
	[super dealloc];
}

@end
