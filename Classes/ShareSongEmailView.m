//
//  ShareSongEmailView.m
//  Solocaster
//
//  Created by Nikki Fernandez on 11/25/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import "ShareSongEmailView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ShareSongEmailView

@synthesize songTitle;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) 
	{
        self.backgroundColor = [UIColor whiteColor];
		songTitle = @"My Song";
		
		// SET GRADIENT COLOR FOR BUTTONS
		UIColor *highColor = [UIColor colorWithRed:0.2941f green:0.2941f blue:0.2941f alpha:1.0f];
		UIColor *lowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
		CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
		[gradientLayer setColors: [NSArray arrayWithObjects:
								   (id)[highColor CGColor], 
								   (id)[lowColor CGColor], nil]];
		CAGradientLayer *gradientLayerSend = [[CAGradientLayer alloc] init];
		[gradientLayerSend setColors: [NSArray arrayWithObjects:
								   (id)[highColor CGColor], 
								   (id)[lowColor CGColor], nil]];
		
		// SETUP SONG BAR
		UIView *songBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 45.0f)];
		songBarView.backgroundColor = [UIColor colorWithRed:0.2706f green:0.2706f blue:0.2706f alpha:1.0f];
		[self addSubview:songBarView];
		
		UILabel *songTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 45.0f)];
		songTitleLabel.backgroundColor = [UIColor clearColor];
		songTitleLabel.font = [UIFont fontWithName:@"Trebuchet MS" size:15];
		songTitleLabel.text = songTitle;
		songTitleLabel.textColor = [UIColor whiteColor];
		songTitleLabel.textAlignment = UITextAlignmentCenter;
		[songBarView addSubview:songTitleLabel];
		[songTitleLabel release];
		
		// SETUP CANCEL BUTTON
		UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cancelButton.frame = CGRectMake(10.0f, 7.0f, 50.0f, 30.0f);
		[gradientLayer setBounds:[cancelButton bounds]];
		[gradientLayer setPosition:CGPointMake([cancelButton bounds].size.width/2,
											   [cancelButton bounds].size.height/2)];
		[[cancelButton layer] insertSublayer:gradientLayer atIndex:0];
		[[cancelButton layer] setCornerRadius:5.0f];
		[[cancelButton layer] setMasksToBounds:YES];
		[[cancelButton layer] setBorderWidth:1.0f];		
		[cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
		cancelButton.titleLabel.font = [UIFont fontWithName:@"Arial" size:12.0f];
		[cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[cancelButton addTarget:self action:@selector(tappedCancelButton:) forControlEvents:UIControlEventTouchUpInside];
		[songBarView addSubview:cancelButton];
		
		// SETUP RECORD NEW SONG BUTTON
		UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
		sendButton.frame = CGRectMake(260.0f, 7.0f, 50.0f, 30.0f);
		[gradientLayerSend setBounds:[sendButton bounds]];
		[gradientLayerSend setPosition:CGPointMake([sendButton bounds].size.width/2,
											   [sendButton bounds].size.height/2)];
		[[sendButton layer] insertSublayer:gradientLayerSend atIndex:0];
		[[sendButton layer] setCornerRadius:5.0f];
		[[sendButton layer] setMasksToBounds:YES];
		[[sendButton layer] setBorderWidth:1.0f];		
		[sendButton setTitle:@"Send" forState:UIControlStateNormal];
		sendButton.titleLabel.font = [UIFont fontWithName:@"Arial" size:12.0f];
		[sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[sendButton addTarget:self action:@selector(tappedSendButton:) forControlEvents:UIControlEventTouchUpInside];
		[songBarView addSubview:sendButton];
		[songBarView release];
		
		// SETUP EMAIL
		UIView *fromView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 45.0f, 320.0f, 45.0f)];
		fromView.layer.borderColor = [UIColor lightGrayColor].CGColor;
		fromView.layer.borderWidth = 1.0f;
		UILabel *fromLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 12.0f, 200.0f, 20.0f)];
		fromLabel.backgroundColor = [UIColor clearColor];
		fromLabel.text = @"Cc/Bcc, From:";
		fromLabel.font = [UIFont fontWithName:@"Arial" size:18.0f];
		fromLabel.textColor = [UIColor lightGrayColor];
		[fromView addSubview:fromLabel];
		[self addSubview: fromView];
		[fromLabel release];
		[fromView release];
		
		emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(130.0f, 47.0f, 180.0f, 41.0f)];
		emailTextField.delegate = self;
		emailTextField.placeholder = @"";
		emailTextField.textColor = [UIColor lightGrayColor];
		emailTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		emailTextField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
		emailTextField.backgroundColor = [UIColor whiteColor];
		emailTextField.font = [UIFont fontWithName:@"Arial" size:18.0f];
		emailTextField.returnKeyType = UIReturnKeyDefault;
		emailTextField.keyboardAppearance = UIKeyboardAppearanceAlert;
		[self addSubview:emailTextField];
		
		// SETUP SUBJECT
		UIView *subjectView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 90.0f, 320.0f, 45.0f)];
		UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 200.0f, 20.0f)];
		subjectLabel.backgroundColor = [UIColor clearColor];
		subjectLabel.text = @"Subject:";
		subjectLabel.font = [UIFont fontWithName:@"Arial" size:18.0f];
		subjectLabel.textColor = [UIColor lightGrayColor];
		[subjectView addSubview:subjectLabel];
		[self addSubview: subjectView];
		[subjectLabel release];
		[subjectView release];
		
		subjectTextField = [[UITextField alloc] initWithFrame:CGRectMake(80.0f, 92.0f, 230.0f, 41.0f)];
		subjectTextField.delegate = self;
		subjectTextField.placeholder = @"";
		subjectTextField.textColor = [UIColor blackColor];
		subjectTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		subjectTextField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
		subjectTextField.backgroundColor = [UIColor whiteColor];
		subjectTextField.font = [UIFont fontWithName:@"Arial" size:18.0f];
		subjectTextField.returnKeyType = UIReturnKeyDefault;
		subjectTextField.keyboardAppearance = UIKeyboardAppearanceAlert;
		[self addSubview:subjectTextField];
		
		// SETUP MESSAGE
		UIView *messageView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 135.0f, 320.0f, 345.0f)];
		messageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
		messageView.layer.borderWidth = 1.0f;
		[self addSubview:messageView];
		
		messageTextField = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, 150.0f, 300.0f, 235.0f)];
		messageTextField.delegate = self;
		messageTextField.placeholder = @"";
		messageTextField.textColor = [UIColor blackColor];
		messageTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
		messageTextField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
		messageTextField.backgroundColor = [UIColor whiteColor];
		messageTextField.font = [UIFont fontWithName:@"Arial" size:18.0f];
		messageTextField.returnKeyType = UIReturnKeyDefault;
		messageTextField.keyboardAppearance = UIKeyboardAppearanceAlert;
		[self addSubview:messageTextField];

    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

-(void) tappedCancelButton:(id)sender
{
	
}

-(void) tappedSendButton:(id)sender
{
	
}

- (void)dealloc 
{
    [super dealloc];
	[emailTextField release];
	[subjectTextField release];
	[messageTextField release];
}


@end
