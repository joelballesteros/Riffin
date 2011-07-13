//
//  UICustomTabBarItem.h
//  Solocaster
//
//  Created by Nikki Fernandez on 12/6/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UICustomTabBarItem : UITabBarItem 
{
	UIImage *customHighlightedImage;
	UIImage *customStdImage;
}

@property (nonatomic, retain) UIImage *customHighlightedImage;
@property (nonatomic, retain) UIImage *customStdImage;

@end