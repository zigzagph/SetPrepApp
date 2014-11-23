//
//  PreviousShowData.m
//  Bisco Set Prep
//
//  Created by MasaP on 3/2/14.
//  Copyright (c) 2014 theDiscoBiscuits. All rights reserved.
//

#import "PreviousShowData.h"

@implementation PreviousShowData

@synthesize showId = _showId;
@synthesize songs = _songs;
@synthesize color = _color;

- (id)initWithShowId:(NSString*)showId withSongs:(NSArray*)songs withColor:(NSColor *)color {
    
    self = [super init];
    
    if (self) {
        _showId = showId;
        _songs = [[NSArray alloc] init];
        _songs = songs;
        _color = color;
    }
    return self;
}

@end
