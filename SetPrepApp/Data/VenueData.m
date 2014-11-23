//
//  VenueData.m
//  Bisco Set Prep
//
//  Created by MasaP on 2/26/14.
//  Copyright (c) 2014 theDiscoBiscuits. All rights reserved.
//

#import "VenueData.h"

@implementation VenueData

@synthesize name = _name;
@synthesize value = _value;

- (id)initWithName:(NSString*)name andValue:(NSString*)value {
    
    self = [super init];
    
    if (self) {
        _name = name;
        _value = value;
    }
    return self;
}


@end
