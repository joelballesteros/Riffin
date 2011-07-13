//
//  InstrumentObject.h
//  Solocaster
//
//  Created by Nikki Fernandez on 11/18/10.
//  Copyright 2010 Appiction. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface InstrumentObject : NSObject 
{
	NSString *name;
	NSString *fileName;
	NSString *extensionType;
	NSString *description;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, retain) NSString *extensionType;
@property (nonatomic, retain) NSString *description;

@end
