//
//  ViewController.m
//  readiOS
//
//  Created by Ingrid Funie on 04/01/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import "ViewController.h"
#import "BookCollectionViewCell.h"
#import "BookDetailsViewController.h"
#import "CustomBookListView.h"
#import "MFSideMenu.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)initializeCollectionViewData
{
    self.bookFavoriteImages = [@[@"three.jpg",@"four.jpg",@"one.jpg",@"two.jpg"] mutableCopy];
    self.bookSuggestedImages = [@[@"1.jpg", @"2.jpg", @"3.jpg", @"4.jpg"] mutableCopy];
    self.bookUniversityImages = [@[@"math.jpg", @"design.jpg", @"java.jpg", @"ai.jpg", @"logic.jpg"] mutableCopy];
    self.bookMathsImages = [@[@"maths1.jpg", @"maths2.jpg"] mutableCopy];
    self.bookRandomImages = [@[@"4.jpg", @"four.jpg", @"ai.jpg"] mutableCopy];
    
    self.pickerViewData = @[@"University", @"Mathematics", @"Random", @"Create New Book List"];
    
    
    self.collectionView.bookImages = self.bookFavoriteImages;
    self.customCollectionView.bookImages = self.bookUniversityImages;
    self.suggestedBooksView.bookImages = self.bookSuggestedImages;
    
    [self.customListButton setTitle:@"University" forState:UIControlStateNormal];
    
    self.readBooks = [[NSMutableArray alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.collectionView registerNibAndCell];
    [self.customCollectionView registerNibAndCell];
    [self.suggestedBooksView registerNibAndCell];
    
    [self initializeCollectionViewData];
    
    [self addGestureRecognizer:self.suggestedBooksView ];
    [self addGestureRecognizer:self.collectionView];
    [self addGestureRecognizer:self.customCollectionView];
}


- (void)addGestureRecognizer:(BookCollectionView *)collView{
    NSLog(@"adding gesture");
    UILongPressGestureRecognizer *lpgr
    = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.5; //seconds
    lpgr.delaysTouchesBegan = YES;
    lpgr.delegate = self;
    [collView addGestureRecognizer:lpgr];
    NSLog(@"added");
    
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    NSLog(@"in here");
    
    CGPoint p = [gestureRecognizer locationInView:gestureRecognizer.view];
    NSIndexPath *indexPath ;
    BookCollectionViewCell* cell ;
    
    
    if (self.collView != nil)
        [self.collView reloadData];
    
    if ([gestureRecognizer.view isEqual:self.collectionView]) {
        indexPath = [self.collectionView indexPathForItemAtPoint:p];
        if (indexPath != nil) {
            cell =[self.collectionView dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
            [self setDataToDelete:self.collectionView imagesArray:self.collectionView.bookImages indexPath:indexPath];
            self.isEditMode = YES;
            [self.collectionView reloadData];
        }
    } else if ([gestureRecognizer.view isEqual:self.customCollectionView]) {
        indexPath = [self.customCollectionView indexPathForItemAtPoint:p];
        if (indexPath != nil) {
            cell =[self.customCollectionView dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
            [self setDataToDelete:self.customCollectionView imagesArray:self.customCollectionView.bookImages indexPath:indexPath];
            self.isEditMode = YES;
            [self.customCollectionView reloadData];
        }
    }
    NSLog(@"getting cell %@", indexPath);
    
    
}

-(void)setDataToDelete:(BookCollectionView *)collView imagesArray:(NSMutableArray *)imagesArray indexPath:(NSIndexPath *)indexPath {
    self.collView = collView;
    self.bookImages = imagesArray;
    self.indexPath = indexPath;
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
        return self.suggestedBooksView.bookImages.count;
    } else if (collectionView == self.collectionView) {
        return self.collectionView.bookImages.count;
    } else if (collectionView == self.customCollectionView) {
        return self.customCollectionView.bookImages.count;
    }
    
    else return 0;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    BookDetailsViewController *bookDetails = [[BookDetailsViewController alloc] initWithNibName:@"BookDetailsViewController" bundle:nil];
    [self presentViewController:bookDetails animated:YES completion:nil];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BookCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
    
    if ([indexPath isEqual:self.indexPath] && self.isEditMode && [collectionView isEqual:self.collView]) {
        cell.deleteButton.hidden = NO;
        cell.readButton.hidden = NO;
        [cell.deleteButton addTarget:self action:@selector(deleteCell:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        cell.deleteButton.hidden = YES;
        cell.readButton.hidden = YES;
        [cell.readButton addTarget:self action:@selector(markBookAsRead:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (collectionView == self.suggestedBooksView) {
        [self saveBookToCell:indexPath cell:cell booksImages:self.suggestedBooksView.bookImages];
    } else if (collectionView == self.collectionView) {
        [self saveBookToCell:indexPath cell:cell booksImages:self.collectionView.bookImages];
    } else if (collectionView == self.customCollectionView) {
        [self saveBookToCell:indexPath cell:cell booksImages:self.customCollectionView.bookImages];
    }
    
    return cell;
    
}


- (void)saveBookToCell:(NSIndexPath *)indexPath cell:(BookCollectionViewCell *)cell booksImages:(NSArray *)booksImages
{
    UIImage *bookImage = [[UIImage alloc] init];
    bookImage = [UIImage imageNamed:[booksImages objectAtIndex:indexPath.row]];
    //later on I can add rating
    /* cell.bookLabel.text = [NSString stringWithFormat:@"Book %li", (long)indexPath.row ];
     [cell.bookLabel sizeToFit];*/
    
    cell.bookImage.image = bookImage;
}

//mock for now, not really showing the books
- (void)markBookAsRead:(UIButton *)sender {
    
    NSLog(@"marked as read");
    if (self.indexPath != nil) {
        
        //later on we will need to add the id of the book.... from the database
        [self.readBooks addObject:[self.collView.bookImages objectAtIndex:self.indexPath.row]];
        
        //then remove it from the orifinal book list and from the specific view
        NSInteger row = [self.indexPath row];
        [self.bookImages removeObjectAtIndex:row];
        NSArray *deletions = @[self.indexPath];
        [self.collView deleteItemsAtIndexPaths:deletions];
    }
    
    [self.collView reloadData];
    
    self.indexPath = nil;
    self.collView = nil;
    self.bookImages = nil;
    
    
    NSLog(@"books read %lu", (unsigned long)self.readBooks.count);
}

-(void)deleteCell:(UIButton *)sender {
    
    NSLog(@"here to delete");
    
    if (self.indexPath != nil) {
        NSInteger row = [self.indexPath row];
        [self.bookImages removeObjectAtIndex:row];
        NSArray *deletions = @[self.indexPath];
        [self.collView deleteItemsAtIndexPaths:deletions];
    }
    
    
    [self.collView reloadData];
    
    self.indexPath = nil;
    self.collView = nil;
    self.bookImages = nil;

}




// Number of components.
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// Total rows in our component.
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.pickerViewData count];
}

// Display each row's data.
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.pickerViewData objectAtIndex: row];
}

// Do something with the selected row.
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSLog(@"You selected this: %@", [self.pickerViewData objectAtIndex: row]);
    //here we need to get the specific list from the cache-database...
    //atm we keep it dummy:
    
    if ([[self.pickerViewData objectAtIndex:row] isEqualToString:@"Create New Book List"]) {
        
        NSLog(@"here");
        
        CustomBookListView *customBookListView = [[CustomBookListView alloc] initWithNibName:@"CustomBookListView" bundle:nil];
        [customBookListView setParentViewController:self];
        [self presentViewController:customBookListView animated:YES completion:nil];//mockup now to see ui works
        
    } else if ([[self.pickerViewData objectAtIndex:row] isEqualToString:@"Mathematics"]) {
        self.customCollectionImages = self.bookMathsImages;
        [self.customListButton setTitle:@"Mathematics" forState:UIControlStateNormal];
        NSLog(@"changed to maths");
    } else if ([[self.pickerViewData objectAtIndex:row] isEqualToString:@"University"]) {
        self.customCollectionImages = self.bookUniversityImages;
        [self.customListButton setTitle:@"University" forState:UIControlStateNormal];
        NSLog(@"changed to uni");
    } else {
        self.customCollectionImages = self.bookRandomImages;
        [self.customListButton setTitle:@"Random" forState:UIControlStateNormal];
        NSLog(@"changed to random");
    }
    
    //we can create a new custom list as well
    
    [self.customCollectionView reloadData];
    
    [self.pickerView removeFromSuperview];
    
}


- (IBAction)customListSelector:(id)sender {
    
    
    self.pickerView = [[UIPickerView alloc] init];
    
    // Calculate the screen's width.
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    float pickerWidth = screenWidth * 3 / 4;
    
    // Calculate the starting x coordinate.
    float xPoint = screenWidth / 2 - pickerWidth / 2;
    
    // Set the picker's frame. We set the y coordinate to 50px.
    [self.pickerView setFrame: CGRectMake(xPoint, 245.0f, pickerWidth, 130.0f)];
    
    [self.pickerView setDataSource:self];
    [self.pickerView setDelegate:self];
    self.pickerView.showsSelectionIndicator = YES;
    self.pickerView.backgroundColor = [UIColor whiteColor];
    
    [self.pickerView selectRow:0 inComponent:0 animated:YES];
    
    [self.view addSubview:self.pickerView];
    
}

- (IBAction)showMenu:(id)sender {
    
    NSLog(@"in side menu here");
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
    
}


@end
