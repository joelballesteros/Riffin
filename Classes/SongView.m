//
//  SongView.m
//  Solocaster
//
//  Created by Nikki Fernandez on 11/4/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import "SongView.h"
#import "TrackObject.h"
#import "InstrumentObject.h"
#import "SongDBDataObject.h"
#import <QuartzCore/QuartzCore.h>

#define ROW_HEIGHT 40.0
#define TABLECELL_TAG 300

@implementation SongView

@synthesize songList;
@synthesize instrumentArray;
@synthesize drumKitArray;

#define LAYOUT_GAP 1

// Color Macro
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) 
	{
		self.backgroundColor = [UIColor blackColor];
		
		// Initialize values
		nc = [NSNotificationCenter defaultCenter];
		
		float ypos = 0.0f;
		//-------------------------------------------------------------------
		// SETUP SONGS NAVIGATION BAR
		
		editDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
		editDoneButton.frame = CGRectMake(240.75f, ypos, 79.25, 50.0f);
		editDoneButton.backgroundColor = RGBA(80, 80, 80, 1);
		[editDoneButton setImage:[UIImage imageNamed:@"edit-btn.png"] forState:UIControlStateNormal];
		//[editDoneButton setImage:[UIImage imageNamed:@"edit-btn-pressed.png"] forState:UIControlStateHighlighted];
		[editDoneButton setImage:[UIImage imageNamed:@"done-btn.png"] forState:UIControlStateSelected];
		[self addSubview:editDoneButton];
		[editDoneButton addTarget:self action:@selector(tappedEditButton:) forControlEvents:UIControlEventTouchUpInside];
		
		editDoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, editDoneButton.bounds.size.height - 15.0f, editDoneButton.bounds.size.width, 10.0f)];
		editDoneLabel.backgroundColor = [UIColor clearColor];
		editDoneLabel.font = [UIFont fontWithName:@"GrixelAcme7WideXtnd" size:8.0f];
		editDoneLabel.textAlignment = UITextAlignmentCenter;
		editDoneLabel.text = @"EDIT";
		editDoneLabel.textColor = RGBA(200, 200, 200, 1);
		[editDoneButton addSubview:editDoneLabel];
		
		UIView *yourSongBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, ypos, 239.75f, 50.0f)];
		yourSongBarView.backgroundColor = RGBA(80, 80, 80, 1);
		[self addSubview:yourSongBarView];
		[yourSongBarView release];
		
		UILabel *yourSongLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, ypos, yourSongBarView.bounds.size.width, yourSongBarView.bounds.size.height)];
		yourSongLabel.backgroundColor = [UIColor clearColor];
		yourSongLabel.font = [UIFont fontWithName:@"GrixelAcme7Wide" size:16];
		yourSongLabel.text = @"Your Songs";
		yourSongLabel.textColor = RGBA(200, 200, 200, 1);
		yourSongLabel.textAlignment = UITextAlignmentLeft;
		[self addSubview:yourSongLabel];
		[yourSongLabel release];
		
		ypos += yourSongBarView.bounds.size.height + LAYOUT_GAP;
		
		//-------------------------------------------------------------------
		songList = [[NSMutableArray alloc] initWithObjects:nil];
		songTracks = [[NSMutableArray alloc] initWithObjects:nil];
		dataSource = [[SolocasterDataSource alloc] init];
				
		songListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, ypos, 320.0, 359.0f)];
		songListTableView.dataSource = self;
		songListTableView.delegate = self;
		songListTableView.separatorColor = [UIColor blackColor];
		songListTableView.backgroundColor = RGBA(160, 160, 160, 1);
		[self addSubview:songListTableView];
    }
    return self;
}

-(void) fillInViewValues
{
	if([songList count] == 0)
	{
		[dataSource loadSongs];
		songList = dataSource.songs;
		//[nc postNotificationName:@"didLoadSongs" object:songList];
	}
}

// Reload of song list should only add new songs to the list at the bottom, should maintain previous order of songs
-(void) reloadList
{
	[songList removeAllObjects];
	[dataSource loadSongs];
	songList = dataSource.songs;
	[songListTableView reloadData];
}

-(void) tappedEditButton:(id) sender
{
	editDoneLabel.highlighted = YES;
	if(songListTableView.editing == NO)
	{
		editDoneLabel.text = @"DONE";
		[editDoneButton setImage:[UIImage imageNamed:@"done-btn-pressed.png"] forState:UIControlStateHighlighted];
		[songListTableView setEditing:YES];
		editDoneButton.selected = YES;
	}
	else 
	{
		editDoneLabel.text = @"EDIT";
		[editDoneButton setImage:[UIImage imageNamed:@"edit-btn-pressed.png"] forState:UIControlStateHighlighted];
		[songListTableView setEditing:NO];
		editDoneButton.selected = NO;
	}
	[songListTableView reloadData];
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [songList count];
}

// Cell height
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return ROW_HEIGHT;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
	NSString *MyIdentifier = [NSString stringWithFormat:@"MyIdentifier %i", indexPath.row];
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];

	SongDBDataObject *aSong = [songList objectAtIndex:indexPath.row];
    if (cell == nil) 
	{
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
		cell.textLabel.font = [UIFont fontWithName:@"GrixelAcme7Wide" size:16];
		cell.textLabel.textColor = RGBA(40, 40, 40, 1);
		cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chevron-right-unselected.png"]];
		cell.showsReorderControl = YES;
		cell.tag = TABLECELL_TAG + indexPath.row;
		
		UIView *selectedCellBgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, ROW_HEIGHT)];
		selectedCellBgView.backgroundColor = RGBA(120, 120, 120, 1);
		cell.selectedBackgroundView = selectedCellBgView;		
		[selectedCellBgView release];
	}
	cell.textLabel.text = aSong.songName;

	return (UITableViewCell *)cell;
}

// SELECT A SONG (NON-EDIT MODE)
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Open Tracks view of selected song
	SongDBDataObject *aSong = [songList objectAtIndex:indexPath.row];
	[dataSource loadTracksForSongWithSongID:aSong.songID];
	songTracks = dataSource.tracks; 
    
	// Create TrackObject
	int i;
	NSMutableArray *trackObjectArray = [[NSMutableArray alloc] initWithObjects:nil];
	TrackObject *aTrackObject;
	
	for(i = 0; i < [songTracks count]; i++)
	{
		aTrackObject = [songTracks objectAtIndex:i];
		
		// Set the player
		if(aTrackObject.isRecorded == YES && i != ([songTracks count] - 1))
		{
			//InstrumentObject *anInstrumentObject = [instrumentArray objectAtIndex:aTrackObject.instrument];
            /*
			aTrackObject.player = [[AVAudioPlayer alloc] 
								   initWithContentsOfURL: [NSURL 
										fileURLWithPath:[[NSBundle mainBundle] 
										pathForResource:[NSString stringWithFormat:@"%@", anInstrumentObject.fileName] 
												 ofType:[NSString stringWithFormat:@"%@", anInstrumentObject.extensionType]]]
													error:nil];
             */
		}
		[trackObjectArray addObject:aTrackObject];
	}
    // Set loop length and tempo
    [nc postNotificationName:@"didToggleLoopLengthSettings" object:[NSNumber numberWithInt:aSong.loopLength]];
    [nc postNotificationName:@"didChangeTempo" object:[NSNumber numberWithInt:aSong.tempo]];
    
	NSDictionary *songDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithInt:aSong.songID], @"songID",
							  aSong.songName, @"songName",
							  trackObjectArray, @"trackObjectArray",
							  nil];
	[nc postNotificationName:@"didTapSongToShowTracks" object: songDict];
	[nc postNotificationName:@"selectMixTabBar" object:nil];
    
	[trackObjectArray release];
}
				 
// EDIT MODE: CHANGE ORDER OF SONGS IN LIST
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath 
{
    SongDBDataObject *song = [[songList objectAtIndex:fromIndexPath.row] retain];
    [songList removeObjectAtIndex:fromIndexPath.row];
    [songList insertObject:song atIndex:toIndexPath.row];
	[nc postNotificationName:@"didRearrangeSongs" object:songList];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return YES;
}

// EDIT MODE: DELETE A SONG FROM LIST
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
	 if (editingStyle == UITableViewCellEditingStyleDelete)
     {
		SongDBDataObject *aSong = [songList objectAtIndex:indexPath.row];

		// Delete from database
		[dataSource deleteSongWithSongID:aSong.songID];
		
		[songList removeObjectAtIndex:indexPath.row];
		[songListTableView reloadData];
     }
}

- (void)dealloc 
{
    [super dealloc];
	[songListTableView release];
	[songList release];
	[songTracks release];
	[dataSource release];
}

@end
