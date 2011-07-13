//
//  BassObject.h
//  Solocaster
//
//  Created by Joel Ballesteros on 5/26/11.
//  Copyright 2011 VirtualPraxis. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "bass.h"
#include "bass_fx.h"


@interface BassObject : NSObject {
    
    HSTREAM chan;
    HFX fxEQ; 
}

@property (nonatomic, assign) HSTREAM chan;
@property (nonatomic, assign) HFX fxEQ;

@end
