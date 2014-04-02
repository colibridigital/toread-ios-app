//
//  ViewController.m
//  readiOS
//
//  Created by Ingrid Funie on 04/01/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import "MainViewController.h"
#import "BookCollectionViewCell.h"
#import "BookDetailsViewController.h"
#import "TWTSideMenuViewController.h"


@interface MainViewController ()

@end

@implementation MainViewController

- (void)initializeCollectionViewData
{
    self.bookFavoriteImages = @[@"one.jpg",@"two.jpg",@"three.jpg",@"four.jpg"];
    self.bookSuggestedImages = @[@"1.jpg", @"2.jpg", @"3.jpg", @"4.jpg"];
    self.bookUniversityImages = @[@"math.jpg", @"design.jpg", @"java.jpg", @"ai.jpg", @"logic.jpg"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.collectionView registerNibAndCell];
    [self.collectionView1 registerNibAndCell];
    [self.suggestedBooksView registerNibAndCell];
    
    [self initializeCollectionViewData];
    
    [self addGestureRecognizer:self.suggestedBooksView];
    [self addGestureRecognizer:self.collectionView];
    [self addGestureRecognizer:self.collectionView1];
    
    
   }

- (void)addGestureRecognizer:(BookCollectionView*)collView
{
    UILongPressGestureRecognizer *lpgr
    = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = .5; //seconds
    lpgr.delaysTouchesBegan = YES;
    lpgr.delegate = self;
    [collView addGestureRecognizer:lpgr];
  }

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    NSLog(@"in here");
   // CGPoint p = [gestureRecognizer locationInView:self.suggestedBooksView];
    
   // NSIndexPath *indexPath = [self.suggestedBooksView indexPathForItemAtPoint:p];
  //  if (indexPath == nil){
 //       NSLog(@"couldn't find index path");
 //   } else {
        // get the cell at indexPath (the one you long pressed)
        // BookCollectionViewCell* cell =[self cellForItemAtIndexPath:indexPath];
        // do stuff with the cell
        BookDetailsViewController *bookDetails = [[BookDetailsViewController alloc] initWithNibName:@"BookDetailsViewController" bundle:nil];
        
        [self presentViewController:bookDetails animated:YES completion:nil];
        
      //  NSLog(@"getting cell %@", indexPath);
  //  }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Collection View Data Sources

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.suggestedBooksView) {
        return self.bookFavoriteImages.count;
    } else if (collectionView == self.collectionView) {
        return self.bookSuggestedImages.count;
    } else if (collectionView == self.collectionView1) {
        return self.bookUniversityImages.count;
    }
    
    else return 0;
}

- (void)saveBookToCell:(NSIndexPath *)indexPath cell:(BookCollectionViewCell *)cell booksImages:(NSArray *)booksImages
{
    UIImage *bookImage = [[UIImage alloc] init];
    bookImage = [UIImage imageNamed:[booksImages objectAtIndex:indexPath.row]];
    cell.bookLabel.text = [NSString stringWithFormat:@"Book %li", (long)indexPath.row ];
    [cell.bookLabel sizeToFit];
    cell.bookImage.image = bookImage;
}

// The cell that is returned must be retrieved from a call to - dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BookCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
    
    if (collectionView == self.suggestedBooksView) {
        [self saveBookToCell:indexPath cell:cell booksImages:self.bookSuggestedImages];
    } else if (collectionView == self.collectionView) {
        [self saveBookToCell:indexPath cell:cell booksImages:self.bookFavoriteImages];
    } else if (collectionView == self.collectionView1) {
        [self saveBookToCell:indexPath cell:cell booksImages:self.bookUniversityImages];
    }
    
    return cell;
}


-(BOOL)prefersStatusBarHidden {
    return true;
}

- (IBAction)sidebarButtonPressed:(id)sender {
    [self.sideMenuViewController openMenuAnimated:YES completion:nil];

}
@end
