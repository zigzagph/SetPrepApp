//
//  CallServer.h
//  Bisco Set Prep
//
//  Created by MasaP on 2/27/14.
//  Copyright (c) 2014 theDiscoBiscuits. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CallServer : NSObject <NSURLConnectionDelegate>

+ (void) ptOnline;
+ (NSData*) getPreviousShowDataBasedOnLocale:(NSString*)locale andNumOfShows:(NSString*)num;
+ (NSData*) getPreviousShowDataBasedOnVenue:(NSString*)venueId andNumOfShows:(NSString*)num;
+ (NSArray*) getTourData;
+ (NSData*) getPreviousShowsData;
+ (NSData*) getInitialData;

@end
