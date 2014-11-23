//
//  AppController.h
//  Bisco Set Prep
//
//  Created by MasaP on 2/28/14.
//  Copyright (c) 2014 theDiscoBiscuits. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CallServer;

@interface AppController : NSObject {
@private
    IBOutlet NSArrayController *arrayController;
    IBOutlet NSArrayController *setlistArrayController;
    NSString *section;
    __weak NSPopUpButton *_localePopup;
    __weak NSPopUpButton *_venuePopup;
}

// Venue Filter
@property (weak) IBOutlet NSTextField *venueNumberFilter;
@property (weak) IBOutlet NSStepper *venueStepper;
@property (weak) IBOutlet NSColorWell *venueColorFilter;
@property (weak) IBOutlet NSPopUpButton *venuePopup;

// Locale Filter
@property (weak) IBOutlet NSTextField *localeNumberFilter;
@property (weak) IBOutlet NSStepper *localeStepper;
@property (weak) IBOutlet NSColorWell *localeColorFilter;
@property (weak) IBOutlet NSPopUpButton *localePopup;

@property (weak) IBOutlet NSTabView *tabView;

// these are the tab views
@property (weak) IBOutlet NSCollectionView *songView;
@property (weak) IBOutlet NSCollectionView *setlistView;

// labels located at the bottom of the screen
@property (weak) IBOutlet NSTextField *totalSongsLabel;
@property (weak) IBOutlet NSTextField *totalVenuesLabel;
@property (weak) IBOutlet NSTextField *totalLocalesLabel;

// progress indicator
@property (weak) IBOutlet NSProgressIndicator *progress;
@property (weak) IBOutlet NSTextField *statusLabel;
@property (weak) NSString* statusString;

// data arrays
@property (strong) NSArray *tourArray;
@property (strong) NSMutableArray *yearArray;
@property (strong) NSMutableArray *songArray;
@property (strong) NSMutableArray *venueArray;
@property (strong) NSMutableArray *localeArray;
@property (strong) NSMutableArray *previousShowsArray;
@property (strong) NSMutableArray *filteredShowsArray;
@property (strong) NSMutableArray *removedSongsArray;
@property (strong) NSMutableArray *setlistViewArray;

@end