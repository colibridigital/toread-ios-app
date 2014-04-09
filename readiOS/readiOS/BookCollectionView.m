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
        //[self addGestureRecognizer];
    }
    return self;
}

- (void)registerNibAndCell
{
    UINib *cellNib = [UINib nibWithNibName:@"BookCollectionViewCell" bundle:nil];
    [self registerNib:cellNib forCellWithReuseIdentifier:@"MY_CELL"];
    //[self addGestureRecognizer];
}

/*- (void)addGestureRecognizer{
    NSLog(@"adding gesture");
    UILongPressGestureRecognizer *lpgr
    = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 2.0; //seconds
    lpgr.delaysTouchesBegan = YES;
    lpgr.delegate = self;
    [self.collView addGestureRecognizer:lpgr];
    NSLog(@"added");
    
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    NSLog(@"in here");
    CGPoint p = [gestureRecognizer locationInView:self.collView];
    
    NSIndexPath *indexPath = [self.collView indexPathForItemAtPoint:p];
      if (indexPath == nil){
          NSLog(@"couldn't find index path");
       } else {
    // get the cell at indexPath (the one you long pressed)
           BookCollectionViewCell* cell =[self.collView dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
    // do stuff with the cell
    
           cell.deleteButton.hidden = NO;
           
           [cell.deleteButton addTarget:self action:@selector(deleteCell:) forControlEvents:UIControlEventTouchUpInside];
        
           NSLog(@"getting cell %@", indexPath);
      }
}

-(void)deleteCell:(UIButton *)sender {
    
    NSLog(@"here to delete");
    
    NSIndexPath *indexPath = [self.collView indexPathForCell:(BookCollectionViewCell *)sender.superview.superview];
    
    NSInteger row = [indexPath row];
    
    [self.bookImages removeObjectAtIndex:row];
    
    NSArray *deletions = @[indexPath];
    
    [self.collView deleteItemsAtIndexPaths:deletions];
    
    // NSLog(@"in favorites collection with index %li", (long)row);
    
    if ([self.selectedCollectionView isEqual:self.collectionView]) {
        
        NSLog(@"in favorites collection with index %li", (long)row);
        
        [self.bookFavoriteImages removeObjectAtIndex:row]; //here i should remove (mark as removed) from all the objects in the database
        
        NSArray *deletions = @[indexPath];
        
        [self.collectionView deleteItemsAtIndexPaths:deletions];
        
    } else if ([self.selectedCollectionView isEqual:self.customCollectionView]) {
        
        NSLog(@"in favorites collection with index %li", (long)row);
        
        if ([self.customListButton.titleLabel.text isEqualToString:@"University"]) {
            [self.bookUniversityImages removeObjectAtIndex:row]; //here i should remove (mark as removed) from all the objects in the database
        } else if ([self.customListButton.titleLabel.text isEqualToString:@"Mathematics"]) {
            [self.bookMathsImages removeObjectAtIndex:row]; //here i should remove (mark as removed) from all the objects in the database
        } else if ([self.customListButton.titleLabel.text isEqualToString:@"Random"]) {
            [self.bookRandomImages removeObjectAtIndex:row]; //here i should remove (mark as removed) from all the objects in the database
            
        }
        
        NSArray *deletions = @[indexPath];
        
        [self.customCollectionView deleteItemsAtIndexPaths:deletions];
        
    }*/
    
//}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


@end
