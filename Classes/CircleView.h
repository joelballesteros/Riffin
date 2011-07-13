//
//  CircleView.h
//  Solocaster
//
//  Created by Nikki Fernandez on 12/10/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CircleView : UIView 
{
	BOOL isSelected;
}

- (void) setAsSelected;
- (void) setAsNotSelected;

@property (nonatomic, assign) BOOL isSelected;
@end
