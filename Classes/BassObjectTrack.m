//
//  BassObject.m
//  Solocaster
//
//  Created by Joel Ballesteros on 5/25/11.
//  Copyright 2011 VirtualPraxis. All rights reserved.
//

#import "BassObjectTrack.h"
//#import "BassObject.h"

#define BASS_CONFIG_IOS_MIXAUDIO 34
//#define BASS_CONFIG_IOS_SPEAKER 39

@implementation BassObjectTrack

@synthesize sampleRate;
//@synthesize bo;

-(id) initWithSound:(NSString*)sound :(int)type :(int)chan
{
	if ((self = [super init]))
	{
        //bo = [[BassObject alloc] init];
        
		[self initBass];
        
        NSString *respath = [sound retain];
        
        NSLog(@"file %@", [respath lastPathComponent]);
        
        ///BASS
        DWORD p;
        float freq;
        BASS_StreamFree(channel[chan]); // free old streams/dsps before opening new
        
        
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
        channel[chan] = BASS_StreamCreateFile(FALSE,[respath cStringUsingEncoding:
                                            NSUTF8StringEncoding],0,0,BASS_SAMPLE_FLOAT|BASS_STREAM_DECODE);
        

        
        // check for MOD
        if (!channel[chan]) channel[chan] = BASS_MusicLoad(FALSE, [respath cStringUsingEncoding:
                                                 NSUTF8StringEncoding], 0, 0, BASS_SAMPLE_FLOAT|BASS_MUSIC_RAMP|BASS_MUSIC_PRESCAN|BASS_STREAM_DECODE,0);
        
        if (!channel) {
            NSLog(@"Can't load stream!");
        } else {
            // update the position slider
            p = (DWORD)BASS_ChannelBytes2Seconds(channel[chan], BASS_ChannelGetLength(channel[chan], BASS_POS_BYTE));
            positionMax = p;
            positionMin = 0;
            
            // get current sample rate
            BASS_ChannelGetAttribute(channel[chan], BASS_ATTRIB_FREQ, &freq);
            oldfreq = freq;
            
            // create a new stream - decoded & resampled :)
            if (!(channel[chan]=BASS_FX_TempoCreate(channel[chan], BASS_SAMPLE_LOOP|BASS_FX_FREESOURCE))){
                NSLog(@"Couldn't create a resampled stream!");
                BASS_StreamFree(channel[chan]);
                BASS_MusicFree(channel[chan]);
            } else {
                
                // set dsp eq to channel
                [self SetDSP_EQ:0.0f :2.5f :0.0f :125.0f :1000.0f :8000.0f :chan];
                
                // set Volume
                //volume= BASS_ChannelSetAttribute(channel, BASS_ATTRIB_VOL, (float)p/100.0f);
                
                
                // update tempo slider
                
                // update rate slider min/max values
                tempoMax = (long)(freq * 1.3f);
                tempoMin = (long)(freq * 0.7f);
                tempo = (long)freq;
                
                sampleRate = [NSString stringWithFormat:@"%dHz", (long)freq];
                
                pitch = 0;              
                
                fxEQ = BASS_ChannelSetFX(channel[chan], BASS_FX_BFX_VOLUME, 1);
                BASS_BFX_VOLUME fx1;
                fx1.fVolume = 4.0f;
                fx1.lChannel = chan;
                BASS_FXSetParameters(fxEQ, &fx1);
                
                // play new created stream
                BASS_ChannelPlay(channel[chan],FALSE);
                
            }
        }

	}
	return self;
}

-(void) initBass
{
    NSLog(@"Initialize BASS");
    //BASS_Free();
    
    BASS_SetConfig(BASS_CONFIG_IOS_MIXAUDIO, 0); // Disable mixing.	To be called before BASS_Init.
    //BASS_SetConfig(BASS_CONFIG_IOS_SPEAKER, 1); // To Speaker.	To be called before BASS_Init.
    
	// check the correct BASS was loaded
	if (HIWORD(BASS_GetVersion())!=BASSVERSION) {
		NSLog(@"An incorrect version of BASS was loaded");
	}
    
    // check the correct BASS_FX was loaded
	if (HIWORD(BASS_FX_GetVersion())!=BASSVERSION) {
		NSLog(@"An incorrect version of FX was loaded");
	}
    
   
	// initialize default device
	if (!BASS_Init(-1,44100,0,NULL,NULL)) {
		NSLog(@"Can't initialize device");
	}
    
    
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty (kAudioSessionProperty_AudioCategory,  sizeof (sessionCategory), &sessionCategory);
    
    
}

- (void)playPause:(int)chan {
	if (BASS_ChannelIsActive(channel[chan]) == BASS_ACTIVE_PLAYING) {
		BASS_Pause();
        
	} else {
		BASS_Start();
	}
}

- (void)play:(int)chan {
		BASS_Start();
}

- (void)pause:(int)chan {
		BASS_Pause();
}

-(void)playStop:(int)chan
{
    if (BASS_ChannelIsActive(channel[chan]) == BASS_ACTIVE_PLAYING) {
		BASS_ChannelStop(channel[chan]);
	}
}

- (void)stop {
    BASS_Stop();
}

-(void)applyPitch:(float)value :(int)chan
{
    NSLog(@"Pitch %f", value);
    BASS_ChannelSetAttribute(channel[chan], BASS_ATTRIB_TEMPO_PITCH, value);
}

-(void)applyReverb:(int)type :(int)chan
{
    //BASS_ChannelRemoveFX(channel[chan], fxEQ);
    
    
    fxEQ = BASS_ChannelSetFX(channel[chan], BASS_FX_BFX_REVERB, 1);
    BASS_BFX_REVERB fx;
    
    if (type == 1) //Low
    {
        fx.fLevel = .4;
        fx.lDelay = 1400;
    }
    else if (type == 2) //Medium
    {        
        fx.fLevel = .5;
        fx.lDelay = 1500;
    }
    else if (type == 3) //High
    {   
        fx.fLevel = .6;
        fx.lDelay = 1600;
    }
    else if (type == 4) //Mic
    {   
        NSLog(@"reverb 4");
        
        fx.fLevel = .4;
        fx.lDelay = 1400;
    }
    
    BOOL result = BASS_FXSetParameters(fxEQ, &fx);
    
    NSLog(@"reverb result %d", result);    
    /*
    fxEQ = BASS_ChannelSetFX(channel[chan], BASS_FX_DX8_REVERB, 1);
    BASS_DX8_REVERB fx;
    
    NSLog(@"applyReverb type %d", type);
    
    if (type == 1) //Low
    {
        fx.fInGain = 0;
        fx.fReverbMix = 0;
        fx.fReverbTime = 1000;
        fx.fHighFreqRTRatio = 0.001;
    }
    else if (type == 2) //Medium
    {        
        fx.fInGain = 0;
        fx.fReverbMix = -5;
        fx.fReverbTime = 1100;
        fx.fHighFreqRTRatio = 0.100;
    }
    else if (type == 3) //High
    {   
        fx.fInGain = 0;
        fx.fReverbMix = -10;
        fx.fReverbTime = 1200;
        fx.fHighFreqRTRatio = 0.200;
    }
    else if (type == 4) //Mic
    {   
        fx.fInGain = 0;
        fx.fReverbMix = -5;
        fx.fReverbTime = 1000;
        fx.fHighFreqRTRatio = 0.100;
    }
    
    BOOL result = BASS_FXSetParameters(fxEQ, &fx);
    NSLog(@"result %d", result);
*/
}

-(void)applyChorus:(int)type :(int)chan
{
    fxEQ = BASS_ChannelSetFX(channel[chan], BASS_FX_BFX_CHORUS, 1);
    BASS_BFX_CHORUS fx;
    
    fx.fDryMix = 1;
    fx.fWetMix = -0.4;
    fx.fFeedback = 0.2;
    fx.fMinSweep = 1.0;
    fx.fMaxSweep = 2.0;
    fx.fRate = 1.0;
    fx.lChannel = BASS_BFX_CHANALL;
    
    BOOL result = BASS_FXSetParameters(fxEQ, &fx);
    NSLog(@"BASS_BFX_CHORUS result %d", result);
    
    /*
    fx.fDryMix = 0.9;
    fx.fWetMix = -0.4;
    fx.fFeedback = 0.5;
    fx.fMinSweep = 1.0;
    fx.fMaxSweep = 2.0;
    fx.fRate = 1.0;
    fx.lChannel = chan;
     */
}

-(void)applyEcho:(int)type :(int)chan
{
    //BASS_ChannelRemoveFX(channel, bo.fxEQ);
    
    fxEQ = BASS_ChannelSetFX(channel[chan], BASS_FX_BFX_ECHO2, 1);
    BASS_BFX_ECHO2 fx;
    
    fx.fDryMix = .02;
    fx.fWetMix = 0.9;
    fx.fFeedback = 0.0;
    fx.fDelay = 0.01;
    fx.lChannel = BASS_BFX_CHANALL;
    
    BOOL result = BASS_FXSetParameters(fxEQ, &fx);
    NSLog(@"result %d", result);
    
    /*
    BASS_DX8_ECHO fx;
    //BASS_DX8_ECHO echo; echo.fFeedback = 0.0; echo.fWetDryMix = 0.0; echo.lPanDelay = 1.0; echo.fLeftDelay = 100.0; echo.fRightDelay = 100.0;
    //BASS_FXGetParameters(bo.fxEQ, fx)
    
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
        fx.fWetDryMix = 10.0;
        fx.fFeedback = -10.0;
        fx.fLeftDelay = 1000.0;
        fx.fRightDelay = 1000.0;
        fx.lPanDelay = false;
    }
    
    BOOL result = BASS_FXSetParameters(fxEQ, &fx);
    NSLog(@"result %d", result);
*/
}

-(void)applyFlanger:(int)type :(int)chan
{    
    fxEQ = BASS_ChannelSetFX(channel[chan], BASS_FX_BFX_FLANGER, 1);    
    BASS_BFX_FLANGER fx;
    
    fx.fWetDry = .0000001;
    fx.fSpeed = 0;
    fx.lChannel = BASS_BFX_CHANALL;
    
    BOOL result = BASS_FXSetParameters(fxEQ, &fx);
    
    NSLog(@"BASS_BFX_FLANGER result %d", result);
    
    /*
    fxEQ = BASS_ChannelSetFX(channel[chan], BASS_FX_DX8_FLANGER, 1);
    BASS_DX8_FLANGER bigAreaParams = { 500.0, 36.0, -15.0, 1.0f, 1, 15.0f, 3};
    BOOL result = BASS_FXSetParameters(fxEQ, &bigAreaParams);
    
    NSLog(@"result %d", result);
 */   
}

-(void)applyVolume:(float)value :(int)chan
{ 
    NSLog(@"applyVolume %f", value); 
    BASS_ChannelSetAttribute(channel[chan], BASS_ATTRIB_VOL, value * 2);
    
    
    /*
    fxEQ = BASS_ChannelSetFX(channel[chan], BASS_FX_BFX_VOLUME, 1);
    BASS_BFX_VOLUME fx1;
    BASS_FXGetParameters(fxEQ, &fx1);
    fx1.fVolume = value;
    fx1.lChannel = chan;
    BASS_FXSetParameters(fxEQ, &fx1);
     */
}

-(void)applyTempo:(float)value :(int)chan
{
    NSLog(@"applyTempo %f", value);    
    BASS_ChannelSetAttribute(channel[chan], BASS_ATTRIB_TEMPO, value); // set tempo
    BASS_ChannelSetPosition(channel[chan], BASS_ChannelGetPosition(channel[chan], BASS_POS_BYTE), BASS_POS_BYTE); // "seek" to current position
}

-(void)applyPosition:(float)value :(int)chan
{
    
}

// update dsp eq
-(void)UpdateFX:(int)b :(int)chan
{
	BASS_BFX_PEAKEQ eq;
    
	int v = pitch;
    
	eq.lBand = b;	// get values of the selected band
	BASS_FXGetParameters(fxEQ, &eq);
	eq.fGain = v;
	BASS_FXSetParameters(fxEQ, &eq);
}

// set dsp eq
-(void)SetDSP_EQ:(float)fGain :(float)fBandwidth :(float)fQ :(float)fCenter_Bass :(float)fCenter_Mid :(float)fCenter_Treble :(int)chan
{
	BASS_BFX_PEAKEQ eq;
    
	// set peaking equalizer effect with no bands
	fxEQ=BASS_ChannelSetFX(channel[chan], BASS_FX_BFX_PEAKEQ,0);
    
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
	[self UpdateFX:0 :chan];
	[self UpdateFX:1 :chan];
	[self UpdateFX:2 :chan];
}

- (void)dealloc 
{
    BASS_Free();
    //[bo release];
    [super dealloc];
}

@end
