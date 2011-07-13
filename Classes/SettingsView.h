//
//  SettingsView.h
//  Solocaster
//
//  Created by Nikki Fernandez on 11/4/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomUISwitch.h"

@interface SettingsView : UIView
{
	BOOL isRecordBeat;
	BOOL isRecordInstrument;

	//UISwitch *recordBeatSwitch;
	UISwitch *recordInstrumentSwitch;
	CustomUISwitch *recordBeatSwitch;
	//CustomUISwitch *recordInstrumentSwitch;
	NSNotificationCenter *nc;
}

@property (nonatomic, assign) BOOL isRecordBeat;
@property (nonatomic, assign) BOOL isRecordInstrument;

-(void) fillInViewValues;
-(void) tappedInfoButton;
-(void) didSwitchRecordBeat;
-(void) didSwitchRecordInstrument;

@end
