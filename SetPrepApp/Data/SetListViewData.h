//
//  SetListViewData.h
//  Bisco Set Prep
//
//  Created by MasaP on 3/12/14.
//  Copyright (c) 2014 theDiscoBiscuits. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SetListViewData : NSObject

@property (strong) NSString *date;
@property (strong) NSString *venue;
@property (strong) NSString *locale;
@property (strong) NSString *setlist;
@property (strong) NSColor *color;

- (id)initWithDate:(NSString*)date atVenue:(NSString*)venue inLocale:(NSString*)locale withSetlist:(NSString*)setlist andColor:(NSColor*)color;

@end
