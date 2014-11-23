//
//  ShowFilter.h
//  Bisco Set Prep
//
//  Created by MasaP on 3/3/14.
//  Copyright (c) 2014 theDiscoBiscuits. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShowFilter : NSObject

@property (strong) NSData* showData;
@property (strong) NSColor* color;

- (id)initWithData:(NSData*)data withColor:(NSColor*)color;

@end
