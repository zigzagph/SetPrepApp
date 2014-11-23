//
//  PreviousShowData.h
//  Bisco Set Prep
//
//  Created by MasaP on 3/2/14.
//  Copyright (c) 2014 theDiscoBiscuits. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PreviousShowData : NSObject

@property (strong) NSString *showId;
@property (strong) NSArray *songs;
@property (strong) NSColor *color;

- (id)initWithShowId:(NSString*)showId withSongs:(NSArray*)songs withColor:(NSColor*)color;

@end
