//
//  InstrumentObject.m
//  Solocaster
//
//  Created by Nikki Fernandez on 11/18/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import "InstrumentObject.h"


@implementation InstrumentObject

@synthesize name;
@synthesize fileName;
@synthesize extensionType;
@synthesize description;

- (void)dealloc 
{
    [super dealloc];
	[name release];
	[fileName release];
	[extensionType release];
	[description release]; 
}

@end
