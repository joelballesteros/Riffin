//
//  LineIndicatorView.m
//  Solocaster
//
//  Created by Nikki Fernandez on 11/22/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import "LineIndicatorView.h"
#define DASH_PATTERN 3

@implementation LineIndicatorView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) 
	{
        // Initialization code
		self.backgroundColor = [UIColor redColor];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect 
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetRGBStrokeColor(context, 0.0f, 0.0f, 0.0f, 1.0f); 
	CGContextSetLineWidth(context, 2.0f);
	
	// Drawing code for dashed lines
	CGFloat dash[] = {DASH_PATTERN, DASH_PATTERN};
	CGContextSetLineDash(context, 0.0f, dash, 2.0f);	
	CGContextMoveToPoint(context, 5.0f, 0.0f);
	CGContextAddLineToPoint(context, 5.0f, 195.0f);
	CGContextStrokePath(context);
	
}

- (void)dealloc 
{
    [super dealloc];
}


@end
