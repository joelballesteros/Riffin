//
//  BassObject.m
//  Solocaster
//
//  Created by Joel Ballesteros on 5/25/11.
//  Copyright 2011 VirtualPraxis. All rights reserved.
//

#import "BassObject.h"
#define BASS_CONFIG_IOS_MIXAUDIO 34
#define BASS_CONFIG_IOS_SPEAKER 39

@implementation BassObjectTrack1

@synthesize sampleRate;

-(id) initWithSound:(NSString*)sound
{
	if ((self = [super init]))
	{
		[self initBass];
        
        NSString *respath = [sound retain];
        
        ///BASS
        DWORD p;
        float freq;
        BASS_StreamFree(chan); // free old streams/dsps before opening new
        
        // create decode channel
        chan = BASS_StreamCreateFile(FALSE,[respath cStringUsingEncoding:
                                            NSUTF8StringEncoding],0,0,BASS_SAMPLE_FLOAT|BASS_STREAM_DECODE);
        
        // check for MOD
        if (!chan) chan = BASS_MusicLoad(FALSE, [respath cStringUsingEncoding:
                                                 NSUTF8StringEncoding], 0, 0, BASS_SAMPLE_FLOAT|BASS_MUSIC_RAMP|BASS_MUSIC_PRESCAN|BASS_STREAM_DECODE,0);
        
        if (!chan) {
            NSLog(@"Can't load stream!");
        } else {
            // update the position slider
            p = (DWORD)BASS_ChannelBytes2Seconds(chan, BASS_ChannelGetLength(chan, BASS_POS_BYTE));
            positionMax = p;
            positionMin = 0;
            
            // get current sample rate
            BASS_ChannelGetAttribute(chan, BASS_ATTRIB_FREQ, &freq);
            oldfreq = freq;
            
            // create a new stream - decoded & resampled :)
            if (!(chan=BASS_FX_TempoCreate(chan, BASS_SAMPLE_LOOP|BASS_FX_FREESOURCE))){
                NSLog(@"Couldn't create a resampled stream!");
                BASS_StreamFree(chan);
                BASS_MusicFree(chan);
            } else {
                
                // set dsp eq to channel
                //[self SetDSP_EQ:0.0f :2.5f :0.0f :125.0f :1000.0f :8000.0f];
                
                // set Volume
                volume= BASS_ChannelSetAttribute(chan, BASS_ATTRIB_VOL, (float)p/100.0f);
                
                
                // update tempo slider
                
                // update rate slider min/max values
                tempoMax = (long)(freq * 1.3f);
                tempoMin = (long)(freq * 0.7f);
                tempo = (long)freq;
                
                sampleRate = [NSString stringWithFormat:@"%dHz", (long)freq];
                
                pitch = 0;
                
                // play new created stream
                BASS_ChannelPlay(chan,FALSE);
            }
        }

	}
	return self;
}

-(void) initBass
{
    BASS_SetConfig(BASS_CONFIG_IOS_MIXAUDIO, 0); // Disable mixing.	To be called before BASS_Init.
    
	// check the correct BASS was loaded
	if (HIWORD(BASS_GetVersion())!=BASSVERSION) {
		NSLog(@"An incorrect version of BASS was loaded");
	}
    
	// initialize default device
	if (!BASS_Init(-1,44100,0,NULL,NULL)) {
		NSLog(@"Can't initialize device");
	}
    
    
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty (kAudioSessionProperty_AudioCategory,  sizeof (sessionCategory), &sessionCategory);
    
    
}

- (void)playPause {
	if (BASS_ChannelIsActive(chan) == BASS_ACTIVE_PLAYING) {
		BASS_Pause();
        
	} else {
		BASS_Start();
	}
}

-(void)playStop
{
    if (BASS_ChannelIsActive(chan) == BASS_ACTIVE_PLAYING) {
		BASS_Stop();
	}
}

-(void)applyPitch:(float)value
{
    BASS_ChannelSetAttribute(chan, BASS_ATTRIB_TEMPO_PITCH, value);
}

-(void)applyReverb:(int)type
{
    BASS_ChannelRemoveFX(chan, fxEQ);
    
    fxEQ = BASS_ChannelSetFX(chan, BASS_FX_DX8_REVERB, 1);
    BASS_DX8_REVERB fx;
    
    if (type == 0) //Low
    {
        fx.fInGain = 0;
        fx.fReverbMix = 0;
        fx.fReverbTime = 500;
        fx.fHighFreqRTRatio = 0.100;
    }
    else if (type == 1) //Medium
    {        
        fx.fInGain = 0;
        fx.fReverbMix = 0;
        fx.fReverbTime = 1500;
        fx.fHighFreqRTRatio = 0.500;
    }
    else if (type== 2) //High
    {   
        fx.fInGain = 0;
        fx.fReverbMix = 0;
        fx.fReverbTime = 3000;
        fx.fHighFreqRTRatio = 0.999;
    }
    
    BOOL result = BASS_FXSetParameters(fxEQ, &fx);
    NSLog(@"result %d", result);

}

-(void)applyVolume:(float)value
{
    BASS_ChannelSetAttribute(chan, BASS_ATTRIB_VOL, value);
}

-(void)applyTempo:(float)value
{
    BASS_ChannelSetAttribute(chan, BASS_ATTRIB_MUSIC_SPEED, value);
}

-(void)applyPosition:(float)value
{
    
}

// update dsp eq
-(void)UpdateFX:(int)b
{
	BASS_BFX_PEAKEQ eq;
    
	int v = pitch;
    
	eq.lBand = b;	// get values of the selected band
	BASS_FXGetParameters(fxEQ, &eq);
	eq.fGain = v;
	BASS_FXSetParameters(fxEQ, &eq);
}

// set dsp eq
-(void)SetDSP_EQ:(float)fGain :(float)fBandwidth :(float)fQ :(float)fCenter_Bass :(float)fCenter_Mid :(float)fCenter_Treble
{
	BASS_BFX_PEAKEQ eq;
    
	// set peaking equalizer effect with no bands
	fxEQ=BASS_ChannelSetFX(chan, BASS_FX_BFX_PEAKEQ,0);
    
	eq.fGain=fGain;
	eq.fQ=fQ;
	eq.fBandwidth=fBandwidth;
	eq.lChannel=BASS_BFX_CHANALL;
    
	// create 1st band for bass
	eq.lBand=0;
	eq.fCenter=fCenter_Bass;
	BASS_FXSetParameters(fxEQ, &eq);
    
	// create 2nd band for mid
	eq.lBand=1;
	eq.fCenter=fCenter_Mid;
	BASS_FXSetParameters(fxEQ, &eq);
    
	// create 3rd band for treble
	eq.lBand=2;
	eq.fCenter=fCenter_Treble;
	BASS_FXSetParameters(fxEQ, &eq);
    
	// update dsp eq
	[self UpdateFX:0];
	[self UpdateFX:1];
	[self UpdateFX:2];
}


- (void)dealloc 
{
    BASS_Free();
    [super dealloc];
}

@end
