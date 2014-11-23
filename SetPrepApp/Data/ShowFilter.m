//
//  ShowFilter.m
//  Bisco Set Prep
//
//  Created by MasaP on 3/3/14.
//  Copyright (c) 2014 theDiscoBiscuits. All rights reserved.
//

#import "ShowFilter.h"

@implementation ShowFilter

@synthesize showData = _showData;
@synthesize color = _color;

- (id)initWithData:(NSData*)data withColor:(NSColor*)color
{
    self = [super init];
    
    if (self) {
        _showData = data;
        _color = color;
    }
    return self;
}

@end
