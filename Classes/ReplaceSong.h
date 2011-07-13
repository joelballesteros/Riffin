//
//  ReplaceSong.h
//  Solocaster
//
//  Created by Nikki Fernandez on 11/30/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SolocasterDataSource.h"

@interface ReplaceSong : NSObject 
{
	int songID;
	NSMutableArray *updatedTracks;    
    int loopLength;
    int tempo;
    
	SolocasterDataSource *dataSource;
}

@property (nonatomic, retain) NSMutableArray *updatedTracks;
@property (nonatomic, assign) int songID;
@property (nonatomic, assign) int loopLength;
@property (nonatomic, assign) int tempo;

-(void) update;

@end
