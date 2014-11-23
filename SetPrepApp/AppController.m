//
//  AppController.m
//  Bisco Set Prep
//
//  Created by MasaP on 2/28/14.
//  Copyright (c) 2014 theDiscoBiscuits. All rights reserved.
//

#import "AppController.h"
#import "TFHpple.h"
#import "SongData.h"
#import "VenueData.h"
#import "CallServer.h"
#import "PreviousShowData.h"
#import "SetListViewData.h"
#import "TabCollectionView.h"

@implementation AppController

@synthesize tourArray, yearArray, songArray, venueArray, localeArray, previousShowsArray, removedSongsArray, filteredShowsArray;
@synthesize venueNumberFilter, venueStepper, venuePopup, venueColorFilter;
@synthesize localeNumberFilter, localeStepper, localePopup, localeColorFilter;
@synthesize songView;
@synthesize totalSongsLabel, totalVenuesLabel, totalLocalesLabel;
@synthesize tabView;
@synthesize setlistView, setlistViewArray;
@synthesize progress, statusLabel, statusString;

- (id)init{
    
    self = [super init];
    
    if (self) {
        // Initalize arrays
        tourArray = [[NSArray alloc] init];
        yearArray = [[NSMutableArray alloc] init];
        songArray = [[NSMutableArray alloc] init];
        venueArray = [[NSMutableArray alloc] init];
        localeArray = [[NSMutableArray alloc] init];
        previousShowsArray = [[NSMutableArray alloc] init];
        removedSongsArray = [[NSMutableArray alloc] init];
        setlistViewArray = [[NSMutableArray alloc] init];
        filteredShowsArray = [[NSMutableArray alloc] init];
    }
    //NSLog(@"AppController");
    
    [tabView setControlTint:1];
    
    return self;
}

- (void) awakeFromNib
{
    // init the textfields which contain the number of shows filter
    [venueNumberFilter setStringValue:[NSString stringWithFormat:@"%ld",(long)[venueStepper integerValue]]];
    [localeNumberFilter setStringValue:[NSString stringWithFormat:@"%ld",(long)[localeStepper integerValue]]];
    
    // Start the progress indicator
    [self startProgress];
    self.statusString = @"Fetching data from servers...";
    
    // Check to see if PT is online
    [CallServer ptOnline];
    
    // grab the initial data and fill the views when the PTOnline notificaiton is received
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:@"PTOnline" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(offline) name:@"PTOffline" object:nil];
    
}

#pragma mark - Actions

// restores filtered songs from the collection view
- (IBAction)restoreFiltered:(id)sender {
    // if the removed songs arrays is empty do nothing
    if ( [removedSongsArray count] != 0 ) {
        // remove the songs in the removedSongsArray from the
        // collection view
        [arrayController addObjects:removedSongsArray];
        [removedSongsArray removeAllObjects];
    }
}

// removed filtered songs from the collection view
- (IBAction)removeFiltered:(id)sender {
    
    // cycles through each song in the songArray
    for ( SongData *song in songArray ) {
        // if the song color is not black then
        // add it to the removedSongsArray
        if ( song.color != [NSColor blackColor] ) {
            [removedSongsArray addObject:song];
        }
    }
    // remove all of the songs in the arraycontroller which
    // will reflect in the CollectionView
    [arrayController removeObjects:removedSongsArray];
}

// increments the text fields number with the stepper
- (IBAction)incrementVenueStepper:(id)sender {
    [venueNumberFilter setStringValue:[NSString stringWithFormat:@"%ld",(long)[sender integerValue]]];
}

- (IBAction)incrementLocaleStepper:(id)sender {
    [localeNumberFilter setStringValue:[NSString stringWithFormat:@"%ld",(long)[sender integerValue]]];
}

- (IBAction)filterVenue:(id)sender {
    // create a search predicate to find the VenueData object with the selected name
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name like %@", [venuePopup titleOfSelectedItem]];
    NSArray *venuePred = [venueArray filteredArrayUsingPredicate:predicate];
    
    // be careful of dupicate venue entries here
    VenueData *pdata = [venuePred objectAtIndex:0];
    
    // now filter the song array based on the received data
    [self filterShowData:[CallServer getPreviousShowDataBasedOnVenue:pdata.value andNumOfShows:[NSString stringWithFormat:@"%ld",(long)[venueStepper integerValue]]] withColor:[venueColorFilter color]];

}

// This is the main filter that is used
- (IBAction)filterLocale:(id)sender {
    // now filter the song array based on the received data
    [self filterShowData:[CallServer getPreviousShowDataBasedOnLocale:[localePopup titleOfSelectedItem] andNumOfShows:[NSString stringWithFormat:@"%ld",(long)[localeStepper integerValue]]] withColor:[localeColorFilter color]];
}

// executes a filter on the song list
- (IBAction)filter3PreviousShows:(id)sender {
    // Start the progress indicator
    [self startProgress];
    
    // get the data from the previous 3 shows.
    [self loadPreviousShows];
    
    // filter the songs in the song list tab
    [self filterSongData:previousShowsArray];
}

// this clears all filters and restores
- (IBAction)clearFilters:(id)sender {
    // cycly through each song in the song list tab
    // and if its colored then change it to black
    for ( SongData *song in songArray ) {
        song.color = [NSColor blackColor];
    }
    
    // Sorts the song array
    NSSortDescriptor *sort=[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [songArray sortUsingDescriptors:[NSArray arrayWithObject:sort]];
    
    // Remove all of the set list view objects
    [setlistViewArray removeAllObjects];
    
    // sets the alpha on the setlist view to 0 or off
    [setlistView setAlphaValue:0.0];
}

- (IBAction)exitApp:(NSButton*)sender {
    // custom termination code
    [NSApp terminate:self];
}

#pragma mark - Data querys

- (void) loadData
{
    // Init the parser with the data from Phantasy Tour
    TFHpple *ptParser = [TFHpple hppleWithHTMLData:[CallServer getInitialData]];
    
    // Query the data
    NSArray *ptNodes = [ptParser searchWithXPathQuery:@"//div[@class='setlist_controls singleFilter']/select/option"];
    
    // parse the data
    for (TFHppleElement *element in ptNodes) {
        
        // determine which section we are parsing
        if ( [[[element firstChild] content] isEqualToString:@"- Choose Tour -"] ) {
            section = @"tour";
        } else if ([[[element firstChild] content] isEqualToString:@"- Choose Year -"] ) {
            section = @"year";
        } else if ([[[element firstChild] content] isEqualToString:@"- Choose Song -"] ) {
            section = @"song";
        } else if ([[[element firstChild] content] isEqualToString:@"- Choose Rating -"] ) {
            section = @"rating";
        } else if ([[[element firstChild] content] isEqualToString:@"- Choose Venue -"] ) {
            section = @"venue";
        } else if ([[[element firstChild] content] isEqualToString:@"- Choose Locale -"] ) {
            section = @"locale";
        }
        
        // add elements to their respective arrays
        if ( [section isEqualToString:@"year"] ) {
            if ( ![[[element firstChild] content] isEqualToString:@"- Choose Year -"] ) {
                [yearArray addObject:[[element firstChild] content]];
            }
        } else if ( [section isEqualToString:@"song"] ) {
            if ( ![[[element firstChild] content] isEqualToString:@"- Choose Song -"] ) {
                SongData *song = [[SongData alloc] initWithName:[[element firstChild] content] andValue:[element objectForKey:@"value"] andColor:[NSColor blackColor]];
                [arrayController addObject:song];
            }
        } else if ( [section isEqualToString:@"venue"] ) {
            if ( ![[[element firstChild] content] isEqualToString:@"- Choose Venue -"] ) {
                VenueData *venue = [[VenueData alloc] initWithName:[[element firstChild] content] andValue:[element objectForKey:@"value"]];
                [venueArray addObject:venue];
            }
        } else if ( [section isEqualToString:@"locale"] ) {
            if ( ![[[element firstChild] content] isEqualToString:@"- Choose Locale -"] ) {
                [localeArray addObject:[[element firstChild] content]];
            }
        }
    }
    
    // get the tours data
    tourArray = [CallServer getTourData];
    
    // print sizes
    //NSLog(@"Years touring : %lu", (unsigned long)[yearArray count]);
    //NSLog(@"Number of Tours : %lu", (unsigned long)[tourArray count]);
    //NSLog(@"Number of Songs played : %lu", (unsigned long)[songArray count]);
    //NSLog(@"Number of Venues played : %lu", (unsigned long)[venueArray count]);
    //NSLog(@"Number of cities played : %lu", (unsigned long)[localeArray count]);
    
    // fill the popup boxes
    // Need some way of dealing with multiple venues like HOB
    for ( VenueData *venue in venueArray ) {
        [venuePopup addItemWithTitle:[venue name]];
    }
    [localePopup addItemsWithTitles:localeArray];
    
    // fill in the abels
    [totalSongsLabel setStringValue:[NSString stringWithFormat:@"%lu",(unsigned long)[songArray count]]];
    [totalVenuesLabel setStringValue:[NSString stringWithFormat:@"%lu",(unsigned long)[venueArray count]]];
    [totalLocalesLabel setStringValue:[NSString stringWithFormat:@"%lu",(unsigned long)[localeArray count]]];
    
    // stop the progress indicator
    [self stopProgress];
    self.statusString = @"";
}




#pragma mark - Alt Song List

- (IBAction)loadAltSongList:(id)sender {
    //NSLog(@"loadAltSongList");
    
    [self clearFilters:nil];
    
    // Create a File Open Dialog class.
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    // Set array of file types @"doc",
    NSArray *fileTypesArray;
    fileTypesArray = [NSArray arrayWithObjects:@"rtf", nil];
    
    // Enable options in the dialog.
    [openDlg setAllowedFileTypes:fileTypesArray];
    [openDlg setAllowsMultipleSelection:FALSE];
    openDlg.canChooseDirectories = NO;
    
    // Display the dialog box. If the OK pressed, process the files.
    if ( [openDlg runModal] == NSOKButton ) {
        NSURL *selection = openDlg.URLs[0];
        //[self processAltSongs:[[selection path] stringByResolvingSymlinksInPath]];
        [self processAltSongs:selection];
    }
}

- (void) processAltSongs:(NSURL *) file
{
    //NSLog(@"processAltSongs with file : %@", [[file path] stringByResolvingSymlinksInPath]);

    // open file and read contents into a string
    NSData *data = [[NSData alloc] initWithContentsOfURL:file];
    NSAttributedString *content = [[NSAttributedString alloc] initWithRTF:data documentAttributes:nil];   // .rtf
    NSString *poo = [content string];

    // remove all the current songs from PT
    [self removeAllSongs];
    
    // create an array of the alt song list and add them to
    // the song array controller
    NSArray *altSongsArray = [poo componentsSeparatedByString:@"\n"];
    for ( NSString *sng in altSongsArray ){
        SongData *song = [[SongData alloc] initWithName:[sng stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] andValue:nil andColor:[NSColor blackColor]];
        [arrayController addObject:song];
    }
    
    // Changes the songs count label
    [totalSongsLabel setStringValue:[NSString stringWithFormat:@"%lu",(unsigned long)[altSongsArray count]]];
}

// Removes all songs from the songs arrayController which will
// reflect in the CollectionView
- (void) removeAllSongs
{
    //NSLog(@"removeAllSongs");
    
    // mutable array of songs to remove
    NSMutableArray *removeSongs = [[NSMutableArray alloc] init];
    
    // cycles through each song in the songArray
    for ( SongData *song in songArray ) {
        // if the song color is black which they all are then
        // add it to the removeSongs array
        if ( song.color == [NSColor blackColor] ) {
            [removeSongs addObject:song];
        }
    }
    // remove all of the songs in the arraycontroller which
    // will reflect in the CollectionView
    [arrayController removeObjects:removeSongs];
}








- (void) loadPreviousShows
{
    // Create and error handler and then fetch the last 3 shows from the PT servers
    NSError *error;
    NSData *previousShowsData = [[NSData alloc] initWithData:[CallServer getPreviousShowsData]];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:previousShowsData options:kNilOptions error:&error];
    NSArray *showJSONs = [json objectForKey:@"aaData"];
    
    // create a color array for each previous show
    NSArray *colorArray = [[NSArray alloc] initWithObjects:[NSColor orangeColor], [NSColor magentaColor], [NSColor blueColor], nil];
    
    // cycly through each show JSON and retreive data
    for (int x = 0; x < [showJSONs count]; x++) {
        NSArray *showData = [showJSONs objectAtIndex:x];
        
        // uncomment this to not display shows without set lists
        //if ( [[showData valueForKey:@"HasSetlist"] boolValue] == YES ) {
            // Grab the data for the setlist from the JSON
            NSString *setlist = [showData valueForKey:@"SetlistDisplay"];
            
            // Grabs each set from the html setlists
            [self displaySet:showData withColor:[colorArray objectAtIndex:x]];
            
            // Instanciate the HTML parser with the setlists data
            TFHpple *showDataParser = [TFHpple hppleWithHTMLData:[setlist dataUsingEncoding:NSUTF8StringEncoding]];
            NSArray *showSongs = [showDataParser searchWithXPathQuery:@"//span/a"];
            NSMutableArray *songs = [[NSMutableArray alloc] init];
            
            // parse the data
            for (TFHppleElement *element in showSongs) {
                [songs addObject:[[element firstChild] content]];
            }
            
            // create a previous show data object with the parsed info and stick it in the
            // previous shows array
            PreviousShowData *show = [[PreviousShowData alloc] initWithShowId:[showData valueForKey:@"Id"] withSongs:songs withColor:[colorArray objectAtIndex:x]];
            [previousShowsArray addObject:show];
        //}
    }
    
    // stop the progress indicator
    [self stopProgress];
}

#pragma mark - Workers

- (void) filterShowData:(NSData*)data withColor:(NSColor*)color
{
    // Start the progress indicator
    [self startProgress];
    
    NSError* error;
    // create a JSON dictionary from the received JSON data
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    // make sure the filtered shows array is empty
    if ([filteredShowsArray count] != 0) {
        [filteredShowsArray removeAllObjects];
    }
    
    // create an array of json data for each show
    NSArray* showsJSON = [json objectForKey:@"aaData"];
    
    // cycle through the json data for each show
    for ( NSArray *showJSON in showsJSON ) {
        
        // if the show has a setlist recorded then parse it and create an array of the songs
        if ( [[showJSON valueForKey:@"HasSetlist"] boolValue] == YES ) {
            // create a string out of the setlist html to parse as data
            NSString *setlist = [showJSON valueForKey:@"SetlistDisplay"];
            
            // Display each set in the filtered tab with the selected color
            [self displaySet:showJSON withColor:color];
            
            // parse and create and array from the html data for each span
            TFHpple *showDataParser = [TFHpple hppleWithHTMLData:[setlist dataUsingEncoding:NSUTF8StringEncoding]];
            NSArray *showSongs = [showDataParser searchWithXPathQuery:@"//span/a"];
            
            // create and array of songs played
            NSMutableArray *songsPlayed = [[NSMutableArray alloc] init];
            
            // cycle through the parsed html data and put each song in the
            // songsPlayed array
            for (TFHppleElement *element in showSongs) {
                [songsPlayed addObject:[[element firstChild] content]];
            }
            
            // init a previous show object with the show data and add it to the previousShowsArray
            PreviousShowData *show = [[PreviousShowData alloc] initWithShowId:[showJSON valueForKey:@"Id"] withSongs:songsPlayed withColor:color];
            [filteredShowsArray addObject:show];
        }
    }
    
    // now filter the song data
    [self filterSongData:filteredShowsArray];
    
    // stop the progress indicator
    [self stopProgress];
}

/*
 This function simply cycles through the show data in the previousShowsArray and if
 it finds a match with any of the previous songs played then the color for that song
 is changed which is reflected in the collection view.
*/
- (void) filterSongData:(NSMutableArray*)arr
{
    // cycle through each song in the bands song list
    for ( SongData *song in songArray ) {
        for ( PreviousShowData *previousShow in arr ) {
            for (NSString *sng in [previousShow songs]) {
                
                if ( [[song.name lowercaseString] isEqualToString:[sng lowercaseString]]) {
                    //NSLog(@"Match found : %@ : %@", song.name, sng);
                    song.color = previousShow.color;
                    break;
                }
                
            }
        }
    }
}

#pragma mark - Convienence

// starts the progress indicator
- (void) startProgress
{
    [progress startAnimation:self];
    [progress setAlphaValue:1.0];
}

// stops the progress indicator
- (void) stopProgress
{
    [progress stopAnimation:self];
    [progress setAlphaValue:0];
}

- (void) offline
{
    NSLog(@"Offline");
    self.statusString = @"Servers unavailable. Check your network settings!! When the internet connection is restored restart the app.";
    [self stopProgress];
}

// Accepts an array and color which gets parsed then displayed in the
// Setlist view tab with appropriate color
- (void) displaySet:(NSArray*)showArray withColor:(NSColor*)color
{
    // Create a set list view
    SetListViewData *slvd = [[SetListViewData alloc] initWithDate:[showArray valueForKey:@"LocalDateTime"]
                                                          atVenue:[showArray valueForKey:@"VenueName"]
                                                         inLocale:[showArray valueForKey:@"VenueLocale"]
                                                      withSetlist:[showArray valueForKey:@"SetlistDisplay"]
                                                         andColor:color];
    
    // search through the setlistview array for a matching object by date
    NSString *showDate = [showArray valueForKey:@"LocalDateTime"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date like %@", [showDate substringToIndex:10]];
    NSArray *setlistPred = [setlistViewArray filteredArrayUsingPredicate:predicate];
    
    // if a matching setlist date is found it is replaced with the
    // latest search
    if ( [setlistPred count] != 0 ) {
        [setlistViewArray removeObject:[setlistPred objectAtIndex:0]];
    }
    
    // add the setlistviewdata object to the array controller
    // which adds to the view by data binding
    [setlistArrayController addObject:slvd];
    
    // set the setlistviews alpha to 1 or on to see the filtered setlists
    [setlistView setAlphaValue:1.0];
}

@end
