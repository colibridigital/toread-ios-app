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
    //loadThisDataTitle from the database titles adding the Create New Book List in the end
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self initiatePickerViewWithTableNames];
    
    self.favouriteCollectionView.bookImages = [@[] mutableCopy];
    self.suggestedBooksView.bookImages = [@[] mutableCopy];
    
    self.customCollectionView.bookImages = [@[] mutableCopy];
    //need to fix the customList thing
    [self.customListButton setTitle:[self.pickerViewData objectAtIndex:1] forState:UIControlStateNormal];
    
    
}

- (void) initiatePickerViewWithTableNames {
    [self.appDelegate getAllDatabaseTableNames];
    self.tableNames = [self.appDelegate.tableNames mutableCopy];
    
    [self.tableNames insertObject:@"" atIndex:0];
    [self.tableNames insertObject:@"Create New List" atIndex:self.tableNames.count];
    
    NSMutableArray *newTable = [NSMutableArray array];
    
    for (NSString* name in self.tableNames) {
        if ([name rangeOfString:@"suggested"].location != NSNotFound || [name rangeOfString:@"read"].location != NSNotFound || [name rangeOfString:@"favourite"].location != NSNotFound) {
            continue;
        } else{
            [newTable addObject:[[name stringByReplacingOccurrencesOfString:@"Books" withString:@""] capitalizedString]];
        }
    }
    
    self.pickerViewData = [newTable mutableCopy];
    
}

- (void)loadCustomListDatabase:(NSString *)customListButtonTitle
{
    self.tableName = [customListButtonTitle lowercaseString];
    NSLog(@"the tile is %@", self.tableName);
    [self.appDelegate initiateCustomBooksListFromTheDatabase:[NSString stringWithFormat:@"%@Books",self.tableName]];
}

- (void)loadCustomListDatabaseAndRefreshView:(NSString *)customListButtonTitle {
    [self loadCustomListDatabase:customListButtonTitle];
    [self.customCollectionView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"load view");
    
    [self.favouriteCollectionView registerNibAndCell];
    [self.customCollectionView registerNibAndCell];
    [self.suggestedBooksView registerNibAndCell];
    
    [self initializeCollectionViewData];
    
    [self loadCustomListDatabase:self.customListButton.titleLabel.text];
    
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
        NSLog(@"in tap for custom");
        bookDetails.indexPath = [self.customCollectionView indexPathForItemAtPoint:p];
        BookCollectionViewCell* cell = (BookCollectionViewCell *)[self.customCollectionView cellForItemAtIndexPath:bookDetails.indexPath];
        
        bookDetails.tableName = [NSString stringWithFormat:@"%@Books",self.tableName];
        NSLog(@"count:%lu", (unsigned long)self.customCollectionView.bookImages.count);
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
            [self setDataToDelete:self.favouriteCollectionView imagesArray:self.favouriteCollectionView.bookImages indexPath:indexPath tableName:@"favouriteBooks"];
            self.isEditMode = YES;
            [self.favouriteCollectionView reloadData];
        }
    } else if ([gestureRecognizer.view isEqual:self.customCollectionView]) {
        indexPath = [self.customCollectionView indexPathForItemAtPoint:p];
        if (indexPath != nil) {
            cell =[self.customCollectionView dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
            [self setDataToDelete:self.customCollectionView imagesArray:self.customCollectionView.bookImages indexPath:indexPath tableName:[NSString stringWithFormat:@"%@Books", self.tableName]];
            self.isEditMode = YES;
            [self.customCollectionView reloadData];
        }
    }
    NSLog(@"getting cell %@", indexPath);
    
    
}

-(void)setDataToDelete:(BookCollectionView *)collView imagesArray:(NSMutableArray *)imagesArray indexPath:(NSIndexPath *)indexPath tableName:(NSString *)tableName{
    
    self.collView = collView;
    self.bookImages = imagesArray;
    self.indexPath = indexPath;
    self.collName = tableName;
    
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
    
    
    NSLog(@"showing book");
    
    if (collectionView == self.suggestedBooksView) {
        
        BooksDatabase *bDB = [self.appDelegate.suggestedBooks objectAtIndex:indexPath.row];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *imageName = [NSString stringWithFormat:@"suggestedBooks%ld.png",(long)bDB.ID];
        NSString* pngFilePath = [docDir stringByAppendingPathComponent:imageName];
        
        if ([fileManager fileExistsAtPath:pngFilePath])
        {
            UIImage *bookImage = [[UIImage alloc] initWithContentsOfFile:pngFilePath];
            cell.bookImage.image = bookImage;
            cell.ID = bDB.ID;
            NSLog(@"loading from memory");
            if (![self.suggestedBooksView.bookImages containsObject:pngFilePath])
                [self.suggestedBooksView.bookImages addObject:pngFilePath];
        } else {
            
            
            NSURL *url = [NSURL URLWithString:bDB.coverLink];
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *bookImage = [[UIImage alloc] initWithData:data]; //i can add this image to an array so i have it in memory all the time; or I can add it to the same book once downloaded and keep it there
            cell.bookImage.image = bookImage;
            
            cell.ID = bDB.ID;
            
            if (![self.suggestedBooksView.bookImages containsObject:pngFilePath] && data!=NULL) {
                [self.suggestedBooksView.bookImages addObject:pngFilePath];
                
                NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                
                // If you go to the folder below, you will find those pictures
                NSLog(@"%@",docDir);
                
                NSLog(@"saving png");
                NSString *imageName = [NSString stringWithFormat:@"suggestedBooks%ld.png",(long)cell.ID];
                NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@",docDir, imageName];
                NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(bookImage)];
                [data1 writeToFile:pngFilePath atomically:YES];
            }
            
        }
        
    } else if (collectionView == self.favouriteCollectionView) {
        BooksDatabase *bDB = [self.appDelegate.favouriteBooks objectAtIndex:indexPath.row];
        
        //if image is stored then show it if not and there is internet connection load it and store it
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *imageName = [NSString stringWithFormat:@"favouriteBooks%ld.png",(long)bDB.ID];
        NSString* pngFilePath = [docDir stringByAppendingPathComponent:imageName];
        
        // NSLog(@"%@", pngFilePath);
        
        if ([fileManager fileExistsAtPath:pngFilePath])
        {
            UIImage *bookImage = [[UIImage alloc] initWithContentsOfFile:pngFilePath];
            cell.bookImage.image = bookImage;
            cell.ID = bDB.ID;
            NSLog(@"loading from memory");
            if (![self.favouriteCollectionView.bookImages containsObject:pngFilePath])
                [self.favouriteCollectionView.bookImages addObject:pngFilePath];
            
        } else {
            
            NSURL *url = [NSURL URLWithString:bDB.coverLink];
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *bookImage = [[UIImage alloc] initWithData:data]; //i can add this image to an array so i have it in memory all the time; or I can add it to the same book once downloaded and keep it there
            cell.bookImage.image = bookImage;
            
            cell.ID = bDB.ID;
            
            if (![self.favouriteCollectionView.bookImages containsObject:pngFilePath] && data!=NULL) {
                [self.favouriteCollectionView.bookImages addObject:pngFilePath];
                
                NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                
                // If you go to the folder below, you will find those pictures
                NSLog(@"%@",docDir);
                
                NSLog(@"saving png");
                NSString *imageName = [NSString stringWithFormat:@"favouriteBooks%ld.png",(long)cell.ID];
                NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@",docDir, imageName];
                NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(bookImage)];
                [data1 writeToFile:pngFilePath atomically:YES];
            }
        }
        
        //make this customizable pls
    } else if (collectionView == self.customCollectionView) {
        BooksDatabase *bDB = [self.appDelegate.customListBooks objectAtIndex:indexPath.row];
        
        //if image is stored then show it if not and there is internet connection load it and store it
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *imageName = [NSString stringWithFormat:@"%@Books%ld.png",self.tableName,(long)bDB.ID];
        
        NSString* pngFilePath = [docDir stringByAppendingPathComponent:imageName];
        
        NSLog(@"%@", pngFilePath);
        
        
        if ([fileManager fileExistsAtPath:pngFilePath])
        {
            UIImage *bookImage = [[UIImage alloc] initWithContentsOfFile:pngFilePath];
            cell.bookImage.image = bookImage;
            cell.ID = bDB.ID;
            NSLog(@"loading from memory custom");
            if (![self.customCollectionView.bookImages containsObject:pngFilePath])
                [self.customCollectionView.bookImages addObject:pngFilePath];
        } else {
            
            NSURL *url = [NSURL URLWithString:bDB.coverLink];
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *bookImage = [[UIImage alloc] initWithData:data]; //i can add this image to an array so i have it in memory all the time; or I can add it to the same book once downloaded and keep it there
            cell.bookImage.image = bookImage;
            
            cell.ID = bDB.ID;
            
            NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            // If you go to the folder below, you will find those pictures
            NSLog(@"%@",docDir);
            
            NSLog(@"saving png");
            NSString *imageName = [NSString stringWithFormat:@"%@Books%ld.png",self.tableName, (long)cell.ID];
            NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@",docDir, imageName];
            NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(bookImage)];
            [data1 writeToFile:pngFilePath atomically:YES];
            
            
            if (![self.customCollectionView.bookImages containsObject:pngFilePath] && data != NULL) {
                [self.customCollectionView.bookImages addObject:pngFilePath];
            }
        }
        
    }
    return cell;
}

- (void)removeImage:(NSString *)filePath
{
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:filePath error:&error];
    if (error){
        NSLog(@"%@", error);
    }
}

//need to fix this!
//mock for now, not really showing the books
- (void)markBookAsRead:(UIButton *)sender {
    
    NSLog(@"marked as read");
    if (self.indexPath != nil) {
        
        BookCollectionViewCell *cell;
        if ([self.collName rangeOfString:@"favourite" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            
            cell = (BookCollectionViewCell*)[self.favouriteCollectionView cellForItemAtIndexPath:self.indexPath];
            
        } else {
            cell = (BookCollectionViewCell*)[self.customCollectionView cellForItemAtIndexPath:self.indexPath];
        }
        //then remove it from the orifinal book list and from the specific view
        
        NSString *imagePath = [self.collView.bookImages objectAtIndex:self.indexPath.row];
        
        UIImage *bookImage = [[UIImage alloc] initWithContentsOfFile:imagePath];
        
        NSLog(@"saving png");
        
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        self.uniqueID  = self.uniqueID + 1;
        
        NSString *imageName = [NSString stringWithFormat:@"readBooks%ld.png", (long)self.uniqueID];;
        NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@",docDir, imageName];
        NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(bookImage)];
        [data1 writeToFile:pngFilePath atomically:YES];
        
        
        
        NSInteger row = [self.indexPath row];
        [self.bookImages removeObjectAtIndex:row];
        NSArray *deletions = @[self.indexPath];
        [self.collView deleteItemsAtIndexPaths:deletions];
        
        [self.appDelegate moveBooksToReadInTheDatabase:self.collName ID:cell.ID indexPath:self.indexPath.row];
        [self.appDelegate deleteBooksToReadFromOriginalTable:self.collName ID:cell.ID indexPath:self.indexPath.row];
        [self removeImage:imagePath];
    }
    
    [self.collView reloadData];
    
    self.indexPath = nil;
    self.collView = nil;
    self.bookImages = nil;
    self.collName = nil;
    
}

//need to fix this
-(void)deleteCell:(UIButton *)sender {
    
    NSLog(@"here to delete");
    
    if (self.indexPath != nil) {
        BookCollectionViewCell *cell;
        if ([self.collName rangeOfString:@"favourite" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            
            cell = (BookCollectionViewCell*)[self.favouriteCollectionView cellForItemAtIndexPath:self.indexPath];
            
        } else {
            cell = (BookCollectionViewCell*)[self.customCollectionView cellForItemAtIndexPath:self.indexPath];
        }
        
        NSInteger row = [self.indexPath row];
        [self.bookImages removeObjectAtIndex:row];
        NSArray *deletions = @[self.indexPath];
        [self.collView deleteItemsAtIndexPaths:deletions];
        //make this generic
        [self.appDelegate deleteBooksToReadFromOriginalTable:self.collName ID:cell.ID indexPath:self.indexPath.row];
    }
    
    
    [self.collView reloadData];
    
    self.indexPath = nil;
    self.collView = nil;
    self.bookImages = nil;
    self.collName = nil;
    
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

//fix this!!! we need to call the database for the books from the table specified in the title
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSLog(@"You selected this: %@", [self.pickerViewData objectAtIndex: row]);
    
    if ([[self.pickerViewData objectAtIndex:row] isEqualToString:@"Create New List"]) {
        
        NSLog(@"here");
        
        CustomBookListView *customBookListView = [[CustomBookListView alloc] initWithNibName:@"CustomBookListView" bundle:nil];
        [customBookListView setParentViewController:self];
        self.customCollectionView.bookImages = self.customCollectionImages;
        [self presentViewController:customBookListView animated:YES completion:nil];//mockup now to see ui works
        
    } else {
        [self.customListButton setTitle:[self.pickerViewData objectAtIndex:row] forState:UIControlStateNormal];
        
        [self loadCustomListDatabaseAndRefreshView:[self.pickerViewData objectAtIndex:row]];
        
        NSLog(@"changed to %@", [self.pickerViewData objectAtIndex:row]);
        
        self.customCollectionView.bookImages = self.customCollectionImages;        
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
    
    [self.pickerView selectRow:0 inComponent:0 animated:NO];
    
    [self.view addSubview:self.pickerView];
    
}

- (IBAction)showMenu:(id)sender {
    
    NSLog(@"in side menu here");
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
    
}


@end
