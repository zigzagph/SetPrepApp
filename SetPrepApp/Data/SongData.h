//
//  SongData.h
//  Bisco Set Prep
//
//  Created by MasaP on 2/26/14.
//  Copyright (c) 2014 theDiscoBiscuits. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SongData : NSObject

@property (strong) NSString *name;
@property (strong) NSString *value;
@property (strong) NSColor *color;

- (id)initWithName:(NSString*)name andValue:(NSString*)value andColor:(NSColor*)color;

@end
