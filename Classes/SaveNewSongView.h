//
//  SaveNewSongView.h
//  Solocaster
//
//  Created by Nikki Fernandez on 11/15/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SolocasterDataSource.h"

@interface SaveNewSongView : UIView <UITextFieldDelegate>
{
	NSString *songName;
	NSMutableArray *trackObjectArray;    
    int loopLength;
    int tempo;
    
	UITextField *songNameTextField;
	
	SolocasterDataSource *dataSource;
	NSNotificationCenter *nc;
}

@property (nonatomic, retain) NSString *songName;
@property (nonatomic, retain) NSMutableArray *trackObjectArray;
@property (nonatomic, assign) int loopLength;
@property (nonatomic, assign) int tempo;

-(void) fillInViewValues;
-(void) tappedCancelButton:(id) sender;
-(void) saveNewSong;

@end