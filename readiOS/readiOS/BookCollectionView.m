//
//  BookCollectionView.m
//  readiOS
//
//  Created by Ingrid Funie on 04/01/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import "BookCollectionView.h"
#import "BookCollectionViewCell.h"

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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


@end
