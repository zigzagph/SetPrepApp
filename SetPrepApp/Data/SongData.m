//
//  SongData.m
//  Bisco Set Prep
//
//  Created by MasaP on 2/26/14.
//  Copyright (c) 2014 theDiscoBiscuits. All rights reserved.
//

#import "SongData.h"

@implementation SongData

@synthesize name = _name;
@synthesize value = _value;
@synthesize color = _color;

- (id)initWithName:(NSString*)name andValue:(NSString*)value andColor:(NSColor*)color {
    
    self = [super init];
    
    if (self) {
        _name = name;
        _value = value;
        _color = color;
    }
    return self;
}

@end
