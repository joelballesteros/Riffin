//
//  MicObjectTrack.m
//  Solocaster
//
//  Created by Joel Ballesteros on 6/3/11.
//  Copyright 2011 VirtualPraxis. All rights reserved.
//

#import "MicObjectTrack.h"

#define BASS_CONFIG_IOS_MIXAUDIO 34
//#define BASS_CONFIG_IOS_SPEAKER 39

@implementation MicObjectTrack

@synthesize sampleRate;

-(id) initWithSound:(NSString*)sound :(int)type
{
	if ((self = [super init]))
	{
        
		[self initBass];
        
        NSString *respath = [sound retain];
        
        NSLog(@"file %@", [respath lastPathComponent]);
        
        ///BASS
        DWORD p;
        float freq;
        BASS_StreamFree(micChan); // free old streams/dsps before opening new
        
        
        if (type == 0) {
            respath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", [respath lastPathComponent]]];
            
            NSLog(@"respath type=0 %@", respath);
        }
        else
        {
            NSArray *wordArray = [[respath lastPathComponent] componentsSeparatedByString: @"."];
            NSLog(@"wordArray %@", wordArray);
            
            respath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@", [wordArray objectAtIndex:0]]  ofType:[NSString stringWithFormat:@"%@", [wordArray objectAtIndex:1]]]; 
            
            NSLog(@"respath type!=0 %@", respath);
        }
        
        // create decode channel
        micChan = BASS_StreamCreateFile(FALSE,[respath cStringUsingEncoding:
                                               NSUTF8StringEncoding],0,0,BASS_SAMPLE_FLOAT|BASS_STREAM_DECODE);
        
        
        
        // check for MOD
        if (!micChan) micChan = BASS_MusicLoad(FALSE, [respath cStringUsingEncoding:
                                                       NSUTF8StringEncoding], 0, 0, BASS_SAMPLE_FLOAT|BASS_MUSIC_RAMP|BASS_MUSIC_PRESCAN|BASS_STREAM_DECODE,0);
        
        if (!micChan) {
            NSLog(@"Can't load stream!");
        } else {
            // update the position slider
            p = (DWORD)BASS_ChannelBytes2Seconds(micChan, BASS_ChannelGetLength(micChan, BASS_POS_BYTE));
            positionMax = p;
            positionMin = 0;
            
            // get current sample rate
            BASS_ChannelGetAttribute(micChan, BASS_ATTRIB_FREQ, &freq);
            oldfreq = freq;
            
            // create a new stream - decoded & resampled :)
            if (!(micChan=BASS_FX_TempoCreate(micChan, BASS_SAMPLE_LOOP|BASS_FX_FREESOURCE))){
                NSLog(@"Couldn't create a resampled stream!");
                BASS_StreamFree(micChan);
                BASS_MusicFree(micChan);
            } else {
                
                // set dsp eq to channel
                [self SetDSP_EQ:0.0f :2.5f :0.0f :125.0f :1000.0f :8000.0f];
                
                // set Volume
                //volume= BASS_ChannelSetAttribute(micChan, BASS_ATTRIB_VOL, (float)p/100.0f);
                
                
                // update tempo slider
                
                // update rate slider min/max values
                tempoMax = (long)(freq * 1.3f);
                tempoMin = (long)(freq * 0.7f);
                tempo = (long)freq;
                
                sampleRate = [NSString stringWithFormat:@"%dHz", (long)freq];
                
                pitch = 0;
                
                [self applyVolume:4.5f];
                
                // play new created stream
                BASS_ChannelPlay(micChan,FALSE);
                
            }
        }
        
	}
	return self;
}

-(void) initBass
{
    BASS_SetConfig(BASS_CONFIG_IOS_MIXAUDIO, 0); // Disable mixing.	To be called before BASS_Init.
    //BASS_SetConfig(BASS_CONFIG_IOS_SPEAKER, 1); // To Speaker.	To be called before BASS_Init.
    
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
	if (BASS_ChannelIsActive(micChan) == BASS_ACTIVE_PLAYING) {
		BASS_Pause();
        
	} else {
		BASS_Start();
	}
}

-(void)playStop
{
    if (BASS_ChannelIsActive(micChan) == BASS_ACTIVE_PLAYING) {
		BASS_Stop();
	}
}

-(void)applyPitch:(float)value
{
    NSLog(@"Pitch %f", value);
    BASS_ChannelSetAttribute(micChan, BASS_ATTRIB_TEMPO_PITCH, value);
}

-(void)applyReverb:(int)type
{
    BASS_ChannelRemoveFX(micChan, fxMicEQ);
    
    fxMicEQ = BASS_ChannelSetFX(micChan, BASS_FX_DX8_REVERB, 1);
    BASS_DX8_REVERB fx;
    
    if (type == 0) //Low
    {
        fx.fInGain = 0;
        fx.fReverbMix = 0;
        fx.fReverbTime = 800;
        fx.fHighFreqRTRatio = 0.003;
    }
    else if (type == 1) //Medium
    {        
        fx.fInGain = 0;
        fx.fReverbMix = 0;
        fx.fReverbTime = 1100;
        fx.fHighFreqRTRatio = 0.002;
    }
    else if (type == 2) //High
    {   
        fx.fInGain = 0;
        fx.fReverbMix = 0;
        fx.fReverbTime = 1300;
        fx.fHighFreqRTRatio = 0.001;
    }
    else if (type == 3) //Mic
    {   
        fx.fInGain = 0;
        fx.fReverbMix = 1;
        fx.fReverbTime = 1000;
        fx.fHighFreqRTRatio = 0.001;
    }
    
    BOOL result = BASS_FXSetParameters(fxMicEQ, &fx);
    NSLog(@"result %d", result);
    
}

-(void)applyEcho:(int)type
{
    //BASS_ChannelRemoveFX(micChan, fxMicEQ);
        
    fxMicEQ = BASS_ChannelSetFX(micChan, BASS_FX_DX8_ECHO, 1);
    
    BASS_DX8_ECHO fx;
    
    if (type == 0) //Low
    {
        fx.fWetDryMix = 80;
        fx.fFeedback = 1;
        fx.fLeftDelay = 150;
        fx.fRightDelay = 150;
        fx.lPanDelay = false;
    }
    else if (type == 1) //Medium
    {        
        fx.fWetDryMix = 0;
        fx.fFeedback = -10;
        fx.fLeftDelay = 1000;
        fx.fRightDelay = 0.0001;
        fx.lPanDelay = false;
    }
    else if (type == 2) //High
    {   
        fx.fWetDryMix = 0;
        fx.fFeedback = -10;
        fx.fLeftDelay = 1000;
        fx.fRightDelay = 0.0001;
        fx.lPanDelay = false;
    }
    else if (type == 3) //Mic
    {   
        fx.fWetDryMix = 40.0;
        fx.fFeedback = -10.0;
        fx.fLeftDelay = 200.0;
        fx.fRightDelay = 200.0;
        fx.lPanDelay = false;
    }
    
    BOOL result = BASS_FXSetParameters(fxMicEQ, &fx);
    NSLog(@"result %d", result);
    
}

-(void)applyVolume:(float)value
{ 
    BASS_ChannelRemoveFX(micChan, fxMicEQ);
    fxMicEQ = BASS_ChannelSetFX(micChan, BASS_FX_BFX_VOLUME, 1);
    BASS_BFX_VOLUME fx1;
    fx1.fVolume = value;
    fx1.lChannel = BASS_BFX_CHANALL;
    BASS_FXSetParameters(fxMicEQ, &fx1);
}

-(void)applyTempo:(float)value
{
    NSLog(@"applyTempo %f", value);    
    BASS_ChannelSetAttribute(micChan, BASS_ATTRIB_TEMPO, value); // set tempo
    BASS_ChannelSetPosition(micChan, BASS_ChannelGetPosition(micChan, BASS_POS_BYTE), BASS_POS_BYTE); // "seek" to current position
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
	BASS_FXGetParameters(fxMicEQ, &eq);
	eq.fGain = v;
	BASS_FXSetParameters(fxMicEQ, &eq);
}

// set dsp eq
-(void)SetDSP_EQ:(float)fGain :(float)fBandwidth :(float)fQ :(float)fCenter_Bass :(float)fCenter_Mid :(float)fCenter_Treble
{
	BASS_BFX_PEAKEQ eq;
    
	// set peaking equalizer effect with no bands
	fxMicEQ=BASS_ChannelSetFX(micChan, BASS_FX_BFX_PEAKEQ,0);
    
	eq.fGain=fGain;
	eq.fQ=fQ;
	eq.fBandwidth=fBandwidth;
	eq.lChannel=BASS_BFX_CHANALL;
    
	// create 1st band for bass
	eq.lBand=0;
	eq.fCenter=fCenter_Bass;
	BASS_FXSetParameters(fxMicEQ, &eq);
    
	// create 2nd band for mid
	eq.lBand=1;
	eq.fCenter=fCenter_Mid;
	BASS_FXSetParameters(fxMicEQ, &eq);
    
	// create 3rd band for treble
	eq.lBand=2;
	eq.fCenter=fCenter_Treble;
	BASS_FXSetParameters(fxMicEQ, &eq);
    
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
