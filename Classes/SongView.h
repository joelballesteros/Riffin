//
//  SongView.h
//  Solocaster
//
//  Created by Nikki Fernandez on 11/4/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SolocasterDataSource.h"

@interface SongView : UIView <UITableViewDelegate, UITableViewDataSource>
{
	BOOL isEdit;
	
	UIButton *editDoneButton;
	UILabel *editDoneLabel;
	
	UIButton *editButton;
	UITableView *songListTableView;

	NSMutableArray *songList;
	NSMutableArray *songTracks;
	NSMutableArray *instrumentArray;
	NSMutableArray *drumKitArray;
	
	SolocasterDataSource *dataSource;
	
	NSNotificationCenter *nc;
}

@property (nonatomic, retain) NSMutableArray *songList;
@property (nonatomic, retain) NSMutableArray *instrumentArray;
@property (nonatomic, retain) NSMutableArray *drumKitArray;

-(void) fillInViewValues;
-(void) reloadList;
-(void) tappedEditButton:(id) sender;

@end
