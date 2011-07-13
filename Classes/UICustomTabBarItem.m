//
//  UICustomTabBarItem.m
//  Solocaster
//
//  Created by Nikki Fernandez on 12/6/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import "UICustomTabBarItem.h"

@implementation UICustomTabBarItem

@synthesize customHighlightedImage;
@synthesize customStdImage;

-(UIImage *) selectedImage
{
    return self.customHighlightedImage;
}

-(UIImage *) unselectedImage
{
    return self.customStdImage;
}

- (void) dealloc
{
    [customHighlightedImage release]; 
	customHighlightedImage = nil;
	[customStdImage release];
	customStdImage = nil;
    [super dealloc];
}

@end
