//
//  UICustomSwitch.h
//  Solocaster
//
//  Created by Nikki Fernandez on 12/6/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import <UIKit/UIKit.h>

// Expose the _UISwitchSlider class 
@interface _UISwitchSlider : UIView 
@end 


@interface UICustomSwitch : UISwitch 
- (void) setLeftLabelText: (NSString *) labelText; 
- (void) setRightLabelText: (NSString *) labelText; 
@end 
