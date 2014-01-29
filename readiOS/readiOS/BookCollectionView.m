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

- (void)addGestureRecognizer
{
    UILongPressGestureRecognizer *lpgr
    = [[UILongPressGestureRecognizer alloc]
       initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = .5; //seconds
    lpgr.delaysTouchesBegan = YES;
    lpgr.delegate = self;
    [self addGestureRecognizer:lpgr];
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    NSLog(@"in here");
    CGPoint p = [gestureRecognizer locationInView:self];
    
    NSIndexPath *indexPath = [self indexPathForItemAtPoint:p];
    if (indexPath == nil){
        NSLog(@"couldn't find index path");
    } else {
        // get the cell at indexPath (the one you long pressed)
        BookCollectionViewCell* cell =[self cellForItemAtIndexPath:indexPath];
        // do stuff with the cell
        
        NSLog(@"getting cell %@", indexPath);
    }
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
