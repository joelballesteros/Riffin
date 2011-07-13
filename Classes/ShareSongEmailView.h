//
//  ShareSongEmailView.h
//  Solocaster
//
//  Created by Nikki Fernandez on 11/25/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ShareSongEmailView : UIView <UITextFieldDelegate>
{
	NSString *songTitle;
	
	UITextField *emailTextField;
	UITextField *subjectTextField;
	UITextField *messageTextField;
}

@property (nonatomic, retain) NSString *songTitle;

-(void) tappedCancelButton:(id)sender;
-(void) tappedSendButton:(id)sender;

@end
