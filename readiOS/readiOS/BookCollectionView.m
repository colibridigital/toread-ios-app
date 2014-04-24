//
//  BookCollectionView.m
//  readiOS
//
//  Created by Ingrid Funie on 04/01/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import "BookCollectionView.h"
#import "BookCollectionViewCell.h"
#import "BookDetailsViewController.h"

@implementation BookCollectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)registerNibAndCell
{
    UINib *cellNib = [UINib nibWithNibName:@"BookCollectionViewCell" bundle:nil];
    [self registerNib:cellNib forCellWithReuseIdentifier:@"MY_CELL"];
}


@end
