//
//  UICustomSwitch.m
//  Solocaster
//
//  Created by Nikki Fernandez on 12/6/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import "UICustomSwitch.h"

typedef enum {
	SIDE_LEFT,
	SIDE_RIGHT
} Side;

@implementation UICustomSwitch 

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}

- (_UISwitchSlider *) slider { 
	return [[self subviews] lastObject]; 
} 

- (UIView *) textHolder { 
	return [[[self slider] subviews] objectAtIndex:2]; 
} 

- (UILabel *) leftLabel { 
	return [[[self textHolder] subviews] objectAtIndex:0]; 
} 

- (UILabel *) rightLabel { 
	return [[[self textHolder] subviews] objectAtIndex:1]; 
} 

- (void)setText:(NSString*)text onImage:(UIImageView*)image side:(Side)side {
	
	CGRect rect;
	
	if ([text isEqualToString:@"FM"])
	{
		rect = CGRectMake(-45.0f, 1.0f, 50.0f, 20.0f);		
	}
	else {
		rect = CGRectMake(-5.0f, 1.0f, 50.0f, 20.0f);
	}
	
	UIColor *color;
	if (side == SIDE_LEFT) {
		color = [UIColor whiteColor];
	} else {
		color = [UIColor grayColor];
	}
	UILabel *label = [[UILabel alloc] initWithFrame: rect];
	image.image = nil;
	image.frame = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
	label.font = [UIFont boldSystemFontOfSize: 17.0f];
	label.textColor = color;
	label.text = text;
	label.textAlignment = UITextAlignmentCenter;
	label.backgroundColor = [UIColor clearColor]; 
	[image addSubview: [label autorelease]];
}
- (void) setLeftLabelText: (NSString *) labelText {
	@try {
		[[self leftLabel] setText:labelText];
	} @catch (NSException *ex) { // international versions of this view uses images
		[self setText: labelText 
			  onImage: (UIImageView*)[self leftLabel]
				 side: SIDE_LEFT];
	}
}
- (void) setRightLabelText: (NSString *) labelText { 
	@try {
		[[self rightLabel] setText:labelText];
	} @catch (NSException *ex) { // international versions of this view uses images
		[self setText: labelText 
			  onImage: (UIImageView*)[self rightLabel]
				 side: SIDE_RIGHT];
	}
}

@end 

