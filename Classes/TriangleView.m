//
//  TriangleView.m
//  Solocaster
//
//  Created by Nikki Fernandez on 11/9/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import "TriangleView.h"
#import <CoreGraphics/CoreGraphics.h>

@implementation TriangleView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) 
	{
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect 
{
    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextBeginPath(context);
	
	CGContextMoveToPoint(context, 5, 0);
	CGContextAddLineToPoint(context, 10, 10);
	CGContextAddLineToPoint(context, 0, 10);
	
	CGContextClosePath(context);
	
	[[UIColor blackColor]setFill];
	[[UIColor blackColor]setStroke];
	CGContextDrawPath(context,kCGPathFillStroke);
}

- (void)dealloc {
    [super dealloc];
}


@end
