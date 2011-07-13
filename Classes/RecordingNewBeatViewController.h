//
//  RecordingNewBeatViewController.h
//  Solocaster
//
//  Created by Nikki Fernandez on 12/21/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordingNewBeatView.h"
#import "SolocasterAppDelegate.h"

@interface RecordingNewBeatViewController : UIViewController 
{
	SolocasterAppDelegate *mainDelegate;
	
	RecordingNewBeatView *recordingNewBeatView;
	NSNotificationCenter *nc;
}

-(void) initializeNotification;
-(void) didSelectRecordNewBeat;
-(void) didCancelRecordNewBeat;
-(void) didSaveRecordNewBeat:(NSNotification *)note;
-(void) didToggleLoopLengthSettings:(NSNotification *) note;
-(void) didMoveNewBeatTimeSlider:(NSNotification *) note;
@end
