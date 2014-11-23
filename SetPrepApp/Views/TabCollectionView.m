//
//  TabCollectionView.m
//  Bisco Set Prep
//
//  Created by MasaP on 3/13/14.
//  Copyright (c) 2014 theDiscoBiscuits. All rights reserved.
//

#import "TabCollectionView.h"

@implementation TabCollectionView

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void) awakeFromNib {
    //NSLog(@"TabCollectionView.h");
}


// Used to print the collectionView of songs.
- (void) print:(id)sender
{
    // Adjusts the CollectionView
    NSPrintInfo *pInfo = [[NSPrintInfo alloc] init];
 
    // Changes the margin
    pInfo.leftMargin = 0.0;
    pInfo.rightMargin = 0.0;
    pInfo.topMargin = 50.0;
    pInfo.bottomMargin = 0.0;
 
    [pInfo setVerticallyCentered:YES];
 
    // Changes the pagination
    pInfo.horizontalPagination = 1; // Fit to page
    /*pInfo.verticalPagination = 0; // Auto*/
 
    // Runs the print operation with the previous options applied
    [[NSPrintOperation printOperationWithView:self printInfo:pInfo] runOperation];
}

@end
