//
//  TempoSliderThumbView.m
//  Solocaster
//
//  Created by Nikki Fernandez on 11/10/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import "TempoSliderThumbView.h"


@implementation TempoSliderThumbView

/*
- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) 
	{
		self.backgroundColor = [UIColor colorWithRed:0.2706f green:0.2706f blue:0.2706f alpha:1.0f];
		
		UILabel *tempoLabel = [[UILabel alloc] initWithFrame:(0.0f, 0.0f, 45.0f, 25.0f)];
		tempoLabel.font = [UIFont fontWithName:@"Trebuchet MS" size:20.0f];
		tempoLabel.textColor = [UIColor whiteColor];
		tempoLabel.backgroundColor = [UIColor clearColor];
		tempoLabel.text = [NSString stringWithFormat:@"%d", tempo];
		tempoLabel.textAlignment = UITextAlignmentLeft;
		[self addSubview:tempoLabel];
		[tempoLabel release];
		
		UILabel *bpmLabel = [[UILabel alloc] initWithFrame:CGRectMake(25.0f, 3.0f, 20.0f, 20.0f)];
		bpmLabel.font = [UIFont fontWithName:@"Trebuchet MS" size:10.0f];
		bpmLabel.textColor = [UIColor whiteColor];
		bpmLabel.backgroundColor = [UIColor clearColor];
		bpmLabel.text = @"bpm";
		bpmLabel.textAlignment = UITextAlignmentCenter;
		bpmLabel.transform = CGAffineTransformMakeRotation(M_PI/(-2));
		[self addSubview:bpmLabel];
		[bpmLabel release];
		
		
    }
    return self;
}*/

- (id) initWithTempo:(int) currTempo
{
	if((self = [super init]))
	{
		self.backgroundColor = [UIColor colorWithRed:0.2706f green:0.2706f blue:0.2706f alpha:1.0f];
		self.frame = CGRectMake(0.0f, 0.0f, 45.0f, 25.0f);
		
		UILabel *tempoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 45.0f, 25.0f)];
		tempoLabel.font = [UIFont fontWithName:@"Trebuchet MS" size:20.0f];
		tempoLabel.textColor = [UIColor whiteColor];
		tempoLabel.backgroundColor = [UIColor clearColor];
		tempoLabel.text = [NSString stringWithFormat:@"%d", currTempo];
		tempoLabel.textAlignment = UITextAlignmentLeft;
		[self addSubview:tempoLabel];
		[tempoLabel release];
		
		UILabel *bpmLabel = [[UILabel alloc] initWithFrame:CGRectMake(25.0f, 3.0f, 20.0f, 20.0f)];
		bpmLabel.font = [UIFont fontWithName:@"Trebuchet MS" size:10.0f];
		bpmLabel.textColor = [UIColor whiteColor];
		bpmLabel.backgroundColor = [UIColor clearColor];
		bpmLabel.text = @"bpm";
		bpmLabel.textAlignment = UITextAlignmentCenter;
		bpmLabel.transform = CGAffineTransformMakeRotation(M_PI/(-2));
		[self addSubview:bpmLabel];
		[bpmLabel release];
	}
	return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [super dealloc];
}


@end
