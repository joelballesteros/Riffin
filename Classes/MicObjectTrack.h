//
//  MicObjectTrack.h
//  Solocaster
//
//  Created by Joel Ballesteros on 6/3/11.
//  Copyright 2011 VirtualPraxis. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "bass.h"
#include "bass_fx.h"
#import <AudioToolbox/AudioToolbox.h>

HSTREAM micChan;
HFX fxMicEQ; 

@interface MicObjectTrack : NSObject {
    float oldfreq;			// old sample rate
    float volume;
    float positionMax;
    float positionMin;
    float tempoMax;
    float tempoMin;
    float tempo;
    float pitch;
    NSString *sampleRate;
}

@property (nonatomic, retain) NSString *sampleRate;

-(id) initWithSound:(NSString*)sound :(int)type;
-(void)initBass;
-(void)playPause;
-(void)playStop;
-(void)applyPitch:(float)value;
-(void)applyReverb:(int)type;
-(void)applyEcho:(int)type;
-(void)applyVolume:(float)value;
-(void)applyTempo:(float)value;
-(void)applyPosition:(float)value;
-(void)UpdateFX:(int)b;
-(void)SetDSP_EQ:(float)fGain :(float)fBandwidth :(float)fQ :(float)fCenter_Bass :(float)fCenter_Mid :(float)fCenter_Treble;


@end
