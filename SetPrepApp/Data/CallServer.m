//
//  CallServer.m
//  Bisco Set Prep
//
//  Created by MasaP on 2/27/14.
//  Copyright (c) 2014 theDiscoBiscuits. All rights reserved.
//

#import "CallServer.h"

// Static PT URL Strings
//static NSString *ptUrl = @"http://www.phantasytour.com/bands/phish/shows";
//static int bandId = 1; // Phish

//static NSString *ptUrl = @"http://www.phantasytour.com/bands/wsp/shows";
//static int bandId = 2; // WSP

//static NSString *ptUrl = @"http://www.phantasytour.com/bands/sci/shows";
//static int bandId = 3; // SCI

static NSString *ptUrl = @"http://www.phantasytour.com/bands/bisco/shows";
static int bandId = 4; // Bisco

//static NSString *ptUrl = @"http://www.phantasytour.com/bands/um/shows";
//static int bandId = 9; // UM

static NSString *url = @"http://www.phantasytour.com/";
static NSString *api = @"api/shows/paged?";

@implementation CallServer

+ (NSData*) getPreviousShowDataBasedOnVenue:(NSString*)venueId andNumOfShows:(NSString*)num
{
    // Create the string to query pt with based on locale
    // This string will query the last 3 shows based on the selected locale
    NSString *queryString = [NSString stringWithFormat:@"%@%@&iDisplayStart=0&iDisplayLength=%@&onlyPastShows=true&BandId=%i&venueId=%@", url, api, num, bandId, venueId];
    return [self makeCallToServer:queryString];
}

+ (NSData*) getPreviousShowDataBasedOnLocale:(NSString*)locale andNumOfShows:(NSString*)num
{
    // Convert the selected city into a correctly encoded string
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"!*'();:@&=+$,/?%#[]\""] invertedSet];
    NSString *encodedString = [locale stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
    NSString *localeString = [encodedString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    // Create the string to query pt with based on locale
    // This string will query the last 3 shows based on the selected locale
    NSString *queryString = [NSString stringWithFormat:@"%@%@&iDisplayStart=0&iDisplayLength=%@&onlyPastShows=true&BandId=%i&locale=%@", url, api, num, bandId, localeString];
    return [self makeCallToServer:queryString];
}

+ (NSData*) getPreviousShowsData
{
    // Create the string to query pt with based on locale
    // This string will query the last 3 shows based on the selected locale
    NSString *queryString = [NSString stringWithFormat:@"%@%@&iDisplayStart=0&iDisplayLength=3&onlyPastShows=true&BandId=%i&timeSpan=past", url, api, bandId];
    return [self makeCallToServer:queryString];
}

+ (NSArray*) getTourData
{
    // This call returns data for venue information.
    // Need to make and explicit call because of multiple venule like HOB
    NSString *query = @"&sColumns=StartDate%2CName&iDisplayStart=0&iDisplayLength=100&iSortCol_0=0&sSortDir_0=desc";
    NSString *queryString = [NSString stringWithFormat:@"%@api/bands/%i/tours/paged?%@", url, bandId, query];
    
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:[self makeCallToServer:queryString] options:kNilOptions error:&error];
    return [json objectForKey:@"aaData"];
}

+ (NSData*) makeCallToServer:(NSString*) queryString
{
    //NSLog(@"Query : %@", queryString);
    // Fetches the data from the Phantasy Tour Server
    NSURL *url = [NSURL URLWithString:queryString];
    NSData *data = [NSData dataWithContentsOfURL:url];    
    return data;
}

+ (NSData*) getInitialData
{
    return [NSData dataWithContentsOfURL:[NSURL URLWithString:ptUrl]];
}

+ (void) ptOnline
{
    [self queryResponseForURL:[NSURL URLWithString:ptUrl]];
}

+ (void) queryResponseForURL:(NSURL *)inURL {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:inURL];
    [request setHTTPMethod:@"GET"];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

+ (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if ( [(NSHTTPURLResponse  *)response statusCode] == 200 ) {
        //NSLog(@"Online");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PTOnline" object:self];
    } else {
        //NSLog(@"Offline");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PTOffline" object:self];
    }
}

@end

/*
 
Maybe use this api to get the correct amount of tours
 /api/bands/4/tours/paged
 
 */
