//
//  CircleView.m
//  Solocaster
//
//  Created by Nikki Fernandez on 12/10/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import "CircleView.h"

@implementation CircleView

@synthesize isSelected;

- (id)initWithFrame:(CGRect)frame 
{    
    self = [super initWithFrame:frame];
    if (self) 
	{
        // Initialization code.
		self.backgroundColor = [UIColor clearColor];
		isSelected = NO;
    }
    return self;
}

- (void) setAsSelected
{
	isSelected = YES;
	[self setNeedsDisplay];
}

- (void) setAsNotSelected
{
	isSelected = NO;
	[self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect 
{
    // Drawing code.
	float diameter = 8.0f;
	CGContextRef contextRef = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(contextRef, 0.0);
	
	if(isSelected == YES)	CGContextSetRGBFillColor(contextRef, 1.0f, 1.0f, 1.0f, 1.0f);
	else					CGContextSetRGBFillColor(contextRef, 0.3137f, 0.3137f, 0.3137f, 1.0f);
	
	CGContextFillEllipseInRect(contextRef, CGRectMake(0.0f, 0.0f, diameter, diameter));
	CGContextStrokeEllipseInRect(contextRef, CGRectMake(0.0f, 0.0f, diameter, diameter));
}

- (void)dealloc {
    [super dealloc];
}


@end
