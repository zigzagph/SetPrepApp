//
//  VenueData.h
//  Bisco Set Prep
//
//  Created by MasaP on 2/26/14.
//  Copyright (c) 2014 theDiscoBiscuits. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VenueData : NSObject

@property (strong) NSString *name;
@property (strong) NSString *value;

- (id)initWithName:(NSString*)name andValue:(NSString*)value;

@end
