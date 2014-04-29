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
#import "BooksDatabase.h"
#import "CustomBookListView.h"
#import "MFSideMenu.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)initializeCollectionViewData
{
    self.bookMathsImages = [@[@"maths1.jpg", @"maths2.jpg"] mutableCopy];
    self.bookRandomImages = [@[@"4.jpg", @"four.jpg", @"ai.jpg"] mutableCopy];
    
    self.pickerViewData = @[@"University", @"Mathematics", @"Random", @"Create New Book List"];
    
    self.favouriteCollectionView.bookImages = [@[] mutableCopy];
    self.suggestedBooksView.bookImages = [@[] mutableCopy];
    
    self.customCollectionView.bookImages = [@[] mutableCopy];
    //need to fix the customList thing
    [self.customListButton setTitle:@"University" forState:UIControlStateNormal];
    
    self.readBooks = [[NSMutableArray alloc] init];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.favouriteCollectionView registerNibAndCell];
    [self.customCollectionView registerNibAndCell];
    [self.suggestedBooksView registerNibAndCell];
    
    [self initializeCollectionViewData];
    
    [self addGestureRecognizer:self.suggestedBooksView ];
    [self addGestureRecognizer:self.favouriteCollectionView];
    [self addGestureRecognizer:self.customCollectionView];
}


- (void)addGestureRecognizer:(BookCollectionView *)collView{
    UILongPressGestureRecognizer *lpgr
    = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.5; //seconds
    lpgr.delaysTouchesBegan = YES;
    lpgr.delegate = self;
    [collView addGestureRecognizer:lpgr];

    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tgr.delegate = self;
    [collView addGestureRecognizer:tgr];
}

-(void)handleTap:(UITapGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    NSLog(@"in tap gesture");
    self.isEditMode = NO;
    
    CGPoint p = [gestureRecognizer locationInView:gestureRecognizer.view];
    
    BookDetailsViewController *bookDetails = [[BookDetailsViewController alloc] initWithNibName:@"BookDetailsViewController" bundle:nil];
    
    
    NSLog(@"handling tap gesture");
    
    //will need to pass on the details a bit more intelligent
    //either call the server for the book details or get them from the local database
    //but we wont pass them on from here for sure!!!
    if ([gestureRecognizer.view isEqual:self.favouriteCollectionView]) {
        bookDetails.indexPath = [self.favouriteCollectionView indexPathForItemAtPoint:p];
        BookCollectionViewCell* cell = (BookCollectionViewCell *)[self.favouriteCollectionView cellForItemAtIndexPath:bookDetails.indexPath];

        bookDetails.tableName = @"favouriteBooks";
        bookDetails.bookImages = self.favouriteCollectionView.bookImages;
        bookDetails.cellID = cell.ID;
    } else if ([gestureRecognizer.view isEqual:self.customCollectionView]) {
        bookDetails.indexPath = [self.customCollectionView indexPathForItemAtPoint:p];
        BookCollectionViewCell* cell = (BookCollectionViewCell *)[self.customCollectionView cellForItemAtIndexPath:bookDetails.indexPath];
        
        bookDetails.tableName = @"suggestedBooks";
        bookDetails.bookImages = self.customCollectionView.bookImages;
        bookDetails.cellID = cell.ID;
    } else if ([gestureRecognizer.view isEqual:self.suggestedBooksView]) {
        bookDetails.indexPath = [self.suggestedBooksView indexPathForItemAtPoint:p];
         BookCollectionViewCell* cell = (BookCollectionViewCell *)[self.customCollectionView cellForItemAtIndexPath:bookDetails.indexPath];
        
        bookDetails.tableName = @"suggestedBooks";
        bookDetails.bookImages = self.suggestedBooksView.bookImages;
        bookDetails.cellID = cell.ID;
    }
    
    [self presentViewController:bookDetails animated:YES completion:nil];
    
    if (self.collView != nil)
        [self.collView reloadData];
    
    [self.pickerView removeFromSuperview];
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

    if ([gestureRecognizer.view isEqual:self.favouriteCollectionView]) {
        indexPath = [self.favouriteCollectionView indexPathForItemAtPoint:p];
        if (indexPath != nil) {
            cell =[self.favouriteCollectionView dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
            [self setDataToDelete:self.favouriteCollectionView imagesArray:self.favouriteCollectionView.bookImages indexPath:indexPath];
            self.isEditMode = YES;
            [self.favouriteCollectionView reloadData];
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
    
    NSLog(@"%lu when setting the data and %lu", (unsigned long)self.bookImages.count, self.collView.bookImages.count);
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
        return self.appDelegate.suggestedBooks.count;
    } else if (collectionView == self.favouriteCollectionView) {
        if (self.favouriteCollectionView.bookImages.count == 0)
            return self.appDelegate.favouriteBooks.count;
        else
            return self.favouriteCollectionView.bookImages.count;
    } else if (collectionView == self.customCollectionView) {
        if (self.customCollectionView.bookImages.count == 0)
            return self.appDelegate.customListBooks.count;
        else
            return self.customCollectionView.bookImages.count;
    }
    
    else return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BookCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
    
    if ([indexPath isEqual:self.indexPath] && self.isEditMode && [collectionView isEqual:self.collView]) {
        cell.deleteButton.hidden = NO;
        cell.readButton.hidden = NO;
        [cell.readButton addTarget:self action:@selector(markBookAsRead:) forControlEvents:UIControlEventTouchUpInside];
        [cell.deleteButton addTarget:self action:@selector(deleteCell:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        cell.deleteButton.hidden = YES;
        cell.readButton.hidden = YES;
        [cell.readButton addTarget:self action:@selector(markBookAsRead:) forControlEvents:UIControlEventTouchUpInside];
        [cell.deleteButton addTarget:self action:@selector(deleteCell:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    if (collectionView == self.suggestedBooksView) {
            BooksDatabase *bDB = [self.appDelegate.suggestedBooks objectAtIndex:indexPath.row];
            NSURL *url = [NSURL URLWithString:bDB.coverLink];
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *bookImage = [[UIImage alloc] initWithData:data]; //i can add this image to an array so i have it in memory all the time; or I can add it to the same book once downloaded and keep it there
            cell.bookImage.image = bookImage;
        
            cell.ID = bDB.ID;
        
        if (![self.suggestedBooksView.bookImages containsObject:data])
            [self.suggestedBooksView.bookImages addObject:data];
        
    } else if (collectionView == self.favouriteCollectionView) {
            BooksDatabase *bDB = [self.appDelegate.favouriteBooks objectAtIndex:indexPath.row];
            NSURL *url = [NSURL URLWithString:bDB.coverLink];
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *bookImage = [[UIImage alloc] initWithData:data]; //i can add this image to an array so i have it in memory all the time; or I can add it to the same book once downloaded and keep it there
            cell.bookImage.image = bookImage;
        
            cell.ID = bDB.ID;
        
        if (![self.favouriteCollectionView.bookImages containsObject:data])
            [self.favouriteCollectionView.bookImages addObject:data];
       
    } else if (collectionView == self.customCollectionView) {
        BooksDatabase *bDB = [self.appDelegate.customListBooks objectAtIndex:indexPath.row];
        NSURL *url = [NSURL URLWithString:bDB.coverLink];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *bookImage = [[UIImage alloc] initWithData:data]; //i can add this image to an array so i have it in memory all the time; or I can add it to the same book once downloaded and keep it there
        cell.bookImage.image = bookImage;
        
        cell.ID = bDB.ID;
        
        if (![self.customCollectionView.bookImages containsObject:data])
            [self.customCollectionView.bookImages addObject:data];
    }
    return cell;
}

//mock for now, not really showing the books
- (void)markBookAsRead:(UIButton *)sender {
    
    NSLog(@"marked as read");
    if (self.indexPath != nil) {
        
        //later on we will need to add the id of the book.... from the database
        [self.readBooks addObject:[self.collView.bookImages objectAtIndex:self.indexPath.row]];
        NSLog(@"%ld the index and the count: %lu, actual %lu, bookImages %lu", (long)self.indexPath.row, (unsigned long)self.collView.bookImages.count, self.favouriteCollectionView.bookImages.count, (unsigned long)self.bookImages.count);
        BookCollectionViewCell *cell = (BookCollectionViewCell*)[self.favouriteCollectionView cellForItemAtIndexPath:self.indexPath];
        //then remove it from the orifinal book list and from the specific view
        NSInteger row = [self.indexPath row];
        [self.bookImages removeObjectAtIndex:row];
        NSArray *deletions = @[self.indexPath];
        [self.collView deleteItemsAtIndexPaths:deletions];
        //make it generic with table name
        
        [self.appDelegate moveBooksToReadInTheDatabase:@"favouriteBooks" ID:cell.ID indexPath:self.indexPath.row];
        [self.appDelegate deleteBooksToReadFromOriginalTable:@"favouriteBooks" ID:cell.ID];
        
        //need to create the readBooks array in the delegate and in here to have the books there
        
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
        BookCollectionViewCell *cell = (BookCollectionViewCell*)[self.favouriteCollectionView cellForItemAtIndexPath:self.indexPath];
        
        NSInteger row = [self.indexPath row];
        [self.bookImages removeObjectAtIndex:row];
        NSArray *deletions = @[self.indexPath];
        [self.collView deleteItemsAtIndexPaths:deletions];
        //make this generic
        [self.appDelegate deleteBooksToReadFromOriginalTable:@"favouriteBooks" ID:cell.ID];
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

//fix this!!!
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSLog(@"You selected this: %@", [self.pickerViewData objectAtIndex: row]);
    //here we need to get the specific list from the cache-database...
    //atm we keep it dummy:
    
    if ([[self.pickerViewData objectAtIndex:row] isEqualToString:@"Create New Book List"]) {
        
        NSLog(@"here");
        
        CustomBookListView *customBookListView = [[CustomBookListView alloc] initWithNibName:@"CustomBookListView" bundle:nil];
        [customBookListView setParentViewController:self];
        self.customCollectionView.bookImages = self.customCollectionImages;
        [self presentViewController:customBookListView animated:YES completion:nil];//mockup now to see ui works
        
    } else if ([[self.pickerViewData objectAtIndex:row] isEqualToString:@"Mathematics"]) {
        self.customCollectionView.bookImages = self.bookMathsImages;
        [self.customListButton setTitle:@"Mathematics" forState:UIControlStateNormal];
        NSLog(@"changed to maths");
    } else if ([[self.pickerViewData objectAtIndex:row] isEqualToString:@"University"]) {
       // self.customCollectionView.bookImages = self.bookUniversityImages;
        [self.customListButton setTitle:@"University" forState:UIControlStateNormal];
        NSLog(@"changed to uni");
    } else {
        self.customCollectionView.bookImages = self.bookRandomImages;
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
