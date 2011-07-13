//
//  AboutView.m
//  Solocaster
//
//  Created by Nikki Fernandez on 12/15/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import "AboutView.h"

@implementation AboutView

#define LAYOUT_GAP 1

// Color Macro
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

- (id)initWithFrame:(CGRect)frame 
{    
    self = [super initWithFrame:frame];
    if (self) 
	{
        self.backgroundColor = [UIColor blackColor];
		nc = [NSNotificationCenter defaultCenter];
		
		float ypos = 0.0f;
		
		//-------------------------------------------------------------------
		// SETUP ABOUT NAVIGATION BAR
		UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
		backButton.frame = CGRectMake(0.0f, ypos, 79.25, 50.0f);
		backButton.backgroundColor = RGBA(80, 80, 80, 1);
		[backButton setImage:[UIImage imageNamed:@"back-btn.png"] forState:UIControlStateNormal];
		[backButton setImage:[UIImage imageNamed:@"back-btn-pressed.png"] forState:UIControlStateHighlighted];
		backButton.selected = YES;
		[self addSubview:backButton];
		[backButton addTarget:self action:@selector(tappedBackButton) forControlEvents:UIControlEventTouchUpInside];
		
		UILabel *backLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, backButton.bounds.size.height - 15.0f, backButton.bounds.size.width, 10.0f)];
		backLabel.backgroundColor = [UIColor clearColor];
		backLabel.font = [UIFont fontWithName:@"GrixelAcme7WideXtnd" size:8.0f];
		backLabel.textAlignment = UITextAlignmentCenter;
		backLabel.text = @"BACK";
		backLabel.textColor = RGBA(200, 200, 200, 1);
		[backButton addSubview:backLabel];
		[backLabel release];
		
		UIView *aboutBarView = [[UIView alloc] initWithFrame:CGRectMake(80.25f, ypos, 320.0f, 50.0f)];
		aboutBarView.backgroundColor = RGBA(80, 80, 80, 1);
		[self addSubview:aboutBarView];
		[aboutBarView release];
		
		UILabel *aboutLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, ypos, 320.0f, aboutBarView.bounds.size.height)];
		aboutLabel.backgroundColor = [UIColor clearColor];
		aboutLabel.font = [UIFont fontWithName:@"GrixelAcme7Wide" size:16];
		aboutLabel.text = @"About";
		aboutLabel.textColor = RGBA(200, 200, 200, 1);
		aboutLabel.textAlignment = UITextAlignmentCenter;
		[self addSubview:aboutLabel];
		[aboutLabel release];
		
		// SETUP ABOUT CONTENTS
		UIView *aboutContentsView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, aboutBarView.bounds.size.height + LAYOUT_GAP, 320.0f, 460.0f - aboutBarView.bounds.size.height + 1.0f)];
		aboutContentsView.backgroundColor = RGBA(80, 80, 80, 1);
		[self addSubview:aboutContentsView];
		
		UILabel *aboutContents = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 0.0f, 290.0f, 100.0f)];
		aboutContents.backgroundColor = [UIColor clearColor];
		aboutContents.font = [UIFont fontWithName:@"GrixelAcme7Wide" size:16];
		aboutContents.text = @"Solocaster Version 1.0 Created by Ben Blatt Developed by Appiction";
		aboutContents.textColor = RGBA(200, 200, 200, 1);
		aboutContents.textAlignment = UITextAlignmentLeft;
		aboutContents.lineBreakMode = UILineBreakModeWordWrap;
		aboutContents.numberOfLines = 0;
		[aboutContentsView addSubview:aboutContents];
		[aboutContents release];
		[aboutContentsView release];
    }
    return self;
}

-(void) tappedBackButton
{
	[nc postNotificationName:@"didGoBackToSettings" object:nil];
}

- (void)dealloc 
{
    [super dealloc];
}


@end
