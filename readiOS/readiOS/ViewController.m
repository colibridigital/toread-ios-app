//
//  ViewController.m
//  readiOS
//
//  Created by Ingrid Funie on 04/01/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import "ViewController.h"
#import "BookCollectionViewCell.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.bookFavoriteImages = @[@"one.jpg",@"two.jpg",@"three.jpg",@"four.jpg"];
    self.bookSuggestedImages = @[@"1.jpg", @"2.jpg", @"3.jpg", @"4.jpg"];
    self.bookUniversityImages = @[@"math.jpg", @"design.jpg", @"java.jpg", @"ai.jpg"];
    
    UINib *cellNib = [UINib nibWithNibName:@"BookCollectionViewCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"MY_CELL"];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Collection View Data Sources

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView.tag == 1) {
        return self.bookFavoriteImages.count;
    } else if (collectionView.tag == 2) {
        return self.bookSuggestedImages.count;
    } else if (collectionView.tag == 3) {
        return self.bookUniversityImages.count;
    }
    
    else return 0;
}

- (void)saveBookToCell:(NSIndexPath *)indexPath cell:(BookCollectionViewCell *)cell booksImages:(NSArray *)booksImages
{
    UIImage *bookImage = [[UIImage alloc] init];
    bookImage = [UIImage imageNamed:[booksImages objectAtIndex:indexPath.row]];
    cell.bookLabel.text = [NSString stringWithFormat:@"Book %i", indexPath.row ];
    [cell.bookLabel sizeToFit];
    cell.bookImage.image = bookImage;
}

// The cell that is returned must be retrieved from a call to - dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BookCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
    
    if (collectionView.tag == 1) {
        [self saveBookToCell:indexPath cell:cell booksImages:self.bookSuggestedImages];
    } else if (collectionView.tag == 2) {
        [self saveBookToCell:indexPath cell:cell booksImages:self.bookFavoriteImages];
    } else if (collectionView.tag == 3) {
        [self saveBookToCell:indexPath cell:cell booksImages:self.bookUniversityImages];
    }
    
    return cell;
}


@end
