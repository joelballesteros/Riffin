//
//  BassObject.h
//  Solocaster
//
//  Created by Joel Ballesteros on 5/25/11.
//  Copyright 2011 VirtualPraxis. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "bass.h"
#include "bass_fx.h"
#import <AudioToolbox/AudioToolbox.h>

//@class BassObject;
HSTREAM channel[4];
HFX fxEQ; 

@interface BassObjectTrack : NSObject {
    
    float oldfreq;			// old sample rate
    float volume;
    float positionMax;
    float positionMin;
    float tempoMax;
    float tempoMin;
    float tempo;
    float pitch;
    NSString *sampleRate;
    
    //BassObject *bo;

}

@property (nonatomic, retain) NSString *sampleRate;
//@property (nonatomic, assign)  BassObject *bo;

-(id) initWithSound:(NSString*)sound :(int)type :(int)chan;
-(void)initBass;
-(void)playPause:(int)chan;
-(void)play:(int)chan;
-(void)stop;
-(void)pause:(int)chan;
-(void)playStop:(int)chan;
-(void)applyPitch:(float)value :(int)chan;
-(void)applyReverb:(int)type :(int)chan;
-(void)applyChorus:(int)type :(int)chan;
-(void)applyEcho:(int)type :(int)chan;
-(void)applyVolume:(float)value :(int)chan;
-(void)applyTempo:(float)value :(int)chan;
-(void)applyPosition:(float)value :(int)chan;
-(void)applyFlanger:(int)type :(int)chan;
-(void)UpdateFX:(int)b :(int)chan;
-(void)SetDSP_EQ:(float)fGain :(float)fBandwidth :(float)fQ :(float)fCenter_Bass :(float)fCenter_Mid :(float)fCenter_Treble :(int)chan;


@end
