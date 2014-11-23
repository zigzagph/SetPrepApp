//
//  SetListViewData.m
//  Bisco Set Prep
//
//  Created by MasaP on 3/12/14.
//  Copyright (c) 2014 theDiscoBiscuits. All rights reserved.
//

#import "SetListViewData.h"
#import "TFHpple.h"

@implementation SetListViewData

@synthesize date = _date;
@synthesize venue = _venue;
@synthesize locale = _locale;
@synthesize setlist = _setlist;

- (id)initWithDate:(NSString*)date atVenue:(NSString*)venue inLocale:(NSString*)locale withSetlist:(NSString*)setlist andColor:(NSColor*)color
{
    self = [super init];
    
    if (self) {
        _date = [date substringToIndex:10];
        _venue = venue;
        _locale = locale;
        _setlist = [self createSetlists:setlist];
        _color = color;
    }
    return self;
}

- (NSString*) createSetlists:(NSString*)s
{
    // Instanciate the HTML parser with the setlists data
    TFHpple *showDataParser = [TFHpple hppleWithHTMLData:[s dataUsingEncoding:NSUTF8StringEncoding]];
    NSArray *setSongs = [showDataParser searchWithXPathQuery:@"//span[@class=\"setlist_partial\"]"];
    NSMutableArray *setlistArray = [[NSMutableArray alloc] init];
     
     // parse the data
    for (TFHppleElement *element in setSongs) {
        NSString *setlist = [self stringByStrippingHTML:[self stripSups:element.raw]];
        [setlistArray addObject:[self removeLeadingGarbage:setlist]];
    }
    //return [NSString stringWithFormat:@"%@\n", setlistArray];
    
    NSMutableString *completeSetlist = [[NSMutableString alloc] init];
    for (NSString *set in setlistArray) {
        NSString *poo = [set stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
        [completeSetlist appendString:[NSString stringWithFormat:@"%@\n\n",poo]];
        //NSLog(@"Set : %@", poo);
    }
    
    return completeSetlist;
}

- (NSString*) stringByStrippingHTML:(NSString*)s
{
    NSRange r;
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}

- (NSString*) stripSups:(NSString*)s
{
    NSRange r;
    while ((r = [s rangeOfString:@"<sup>(.*?)</sup>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}

- (NSString*) removeLeadingGarbage:(NSString*)s
{
    NSRange r;
    while ((r = [s rangeOfString:@"^\\&\\#13\\;\n" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}

@end
