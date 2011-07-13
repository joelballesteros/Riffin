//
//  MicRecording.h
//  Solocaster
//
//  Created by Joel Ballesteros on 2/28/11.
//  Copyright 2011 VirtualPraxis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioQueue.h>
#import <AudioToolbox/AudioFile.h>

#define NUM_BUFFERS 3
#define kAudioConverterPropertyMaximumOutputPacketSize		'xops'
#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

typedef struct
{
	AudioFileID                 audioFile;
	AudioStreamBasicDescription dataFormat;
	AudioQueueRef               queue;
	AudioQueueBufferRef         buffers[NUM_BUFFERS];
	UInt32                      bufferByteSize; 
	SInt64                      currentPacket;
	BOOL                        recording;
} RecordState;

@interface MicRecording : NSObject {
	RecordState recordState;
	AudioQueueRef  audioQueue;
}

@property (nonatomic, assign) AudioQueueRef  audioQueue;

- (BOOL)	isRecording;
- (float)	averagePower;
- (float)	peakPower;
- (float)	currentTime;
- (BOOL)	startRecording: (NSString *) filePath;
- (void)	stopRecording;
- (void)	pause;
- (BOOL)	resume;

@end
