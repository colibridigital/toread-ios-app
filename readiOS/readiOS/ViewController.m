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
#import "MFSideMenu.h"
#import "SearchResultsController.h"
#import "BarcodeScannerViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)initializeCollectionViewData
{
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self initiatePickerViewWithTableNames];
    // self.suggestedBooksView.bookImages = [@[] mutableCopy];
    [self.customListButton setTitle:[self.pickerViewData objectAtIndex:1] forState:UIControlStateNormal];
    
    self.retrieveBooks = [[RetrieveBooks alloc] init];
    
    self.uniqueID = [self.appDelegate getNumberOfReadBooksFromDB];
    NSLog(@"read Books count %i", self.uniqueID);
    
}

- (void) initiatePickerViewWithTableNames {
    [self.appDelegate getAllDatabaseTableNames];
    self.tableNames = [self.appDelegate.tableNames mutableCopy];
    
    [self.tableNames insertObject:@"" atIndex:0];
    [self.tableNames insertObject:@"Create New List" atIndex:self.tableNames.count];
    
    NSMutableArray *newTable = [NSMutableArray array];
    
    for (NSString* name in self.tableNames) {
        if ([name rangeOfString:@"suggested"].location != NSNotFound || [name rangeOfString:@"read"].location != NSNotFound || [name rangeOfString:@"favourite"].location != NSNotFound ) {
            continue;
        } else{
            [newTable addObject:[[name stringByReplacingOccurrencesOfString:@"Books" withString:@""] capitalizedString]];
        }
    }
    
    self.pickerViewData = [newTable mutableCopy];
    
}

- (void)showSimple:(NSString*)urlString {
	// The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
	HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
	
	// Regiser for HUD callbacks so we can remove it from the window at the right time
	HUD.delegate = self;
	
	// Show the HUD while the provided method executes in a new thread
	[HUD showWhileExecuting:@selector(searchInBackground:) onTarget:self withObject:urlString animated:YES];
}

- (void)showWithCustomView:(NSString*)message {
	
	HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
	
	// The sample image is based on the work by http://www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
	// Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
	HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark@2x.png"]];
	
	// Set custom view mode
	HUD.mode = MBProgressHUDModeCustomView;
	
	HUD.delegate = self;
    //modify this according to the needs
	HUD.labelText = message;
	
	[HUD show:YES];
	[HUD hide:YES afterDelay:1.5];
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
    NSLog(@"books images count %lu", (unsigned long)self.customCollectionView.bookImages.count);
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
    [self.appDelegate loadFavouriteDatabase];
    [self.appDelegate initializeSuggestedBooksDatabase];
    
    [self.suggestedBooksView reloadData];
    [self.customCollectionView reloadData];
    [self.favouriteCollectionView reloadData];
    
    [self addGestureRecognizer:self.suggestedBooksView];
    [self addGestureRecognizer:self.favouriteCollectionView];
    [self addGestureRecognizer:self.customCollectionView];
    
    self.searchBar.delegate = self;
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    NSLog(@"show view");
    
    self.searchBar.text = nil;
    
    [self initiatePickerViewWithTableNames];
    
    if ([self.tableNames containsObject:[[self.customListButton.titleLabel.text lowercaseString] stringByAppendingString:@"Books"]]) {
        [self loadCustomListDatabaseAndRefreshView:self.customListButton.titleLabel.text];
    } else {
        [self.customListButton setTitle:@"Create New List" forState:UIControlStateNormal];
        [self loadCustomListDatabaseAndRefreshView:self.customListButton.titleLabel.text];
    }
    [self.appDelegate loadFavouriteDatabase];
    [self.appDelegate initializeSuggestedBooksDatabase];
    [self.favouriteCollectionView reloadData];
    [self.suggestedBooksView reloadData];
    
}

- (void)searchInBackground:(NSString *)urlString {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
        
        NSData* dataFromURL = [self.retrieveBooks getDataFromURLAsData:
                               [NSString stringWithFormat:@"https://www.googleapis.com/books/v1/volumes?q=%@&maxResults=30", urlString]];
        
        
        dispatch_sync(dispatch_get_main_queue(), ^(void) {
            SearchResultsController *searchResController = [[SearchResultsController alloc]initWithNibName:@"SearchResultsController" bundle:nil];
            
            [searchResController setTableData:[self.retrieveBooks parseJson:[self.retrieveBooks getJsonFromData:dataFromURL]]];
            
            [self presentViewController:searchResController animated:NO completion:nil];
            
        });
    });
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [self.pickerView removeFromSuperview];
    
    NSString* searchBarText = self.searchBar.text;
    NSString* urlString = [searchBarText stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
   
    if ([self.appDelegate connectedToInternet]) {
        [self showSimple:urlString];
        [self searchInBackground:urlString];
    } else {
        [self showWithCustomView:@"No Internet Connection"];
    }
    
    [self.searchBar resignFirstResponder];
    //self.searchBar.text = nil;
}


- (void)addGestureRecognizer:(BookCollectionView *)collView{
    UILongPressGestureRecognizer *lpgr
    = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0; //seconds
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
    
    if ([gestureRecognizer.view isEqual:self.favouriteCollectionView]) {
        bookDetails.indexPath = [self.favouriteCollectionView indexPathForItemAtPoint:p];
        BookCollectionViewCell* cell = (BookCollectionViewCell *)[self.favouriteCollectionView cellForItemAtIndexPath:bookDetails.indexPath];
        
        bookDetails.tableName = @"favouriteBooks";
        bookDetails.cellID = cell.ID;
    } else if ([gestureRecognizer.view isEqual:self.customCollectionView]) {
        NSLog(@"in tap for custom");
        bookDetails.indexPath = [self.customCollectionView indexPathForItemAtPoint:p];
        BookCollectionViewCell* cell = (BookCollectionViewCell *)[self.customCollectionView cellForItemAtIndexPath:bookDetails.indexPath];
        
        bookDetails.tableName = [NSString stringWithFormat:@"%@Books",self.tableName];
        bookDetails.cellID = cell.ID;
    } else if ([gestureRecognizer.view isEqual:self.suggestedBooksView]) {
        bookDetails.indexPath = [self.suggestedBooksView indexPathForItemAtPoint:p];
        BookCollectionViewCell* cell = (BookCollectionViewCell *)[self.suggestedBooksView cellForItemAtIndexPath:bookDetails.indexPath];
        
        bookDetails.tableName = @"suggestedBooks";
        bookDetails.cellID = cell.ID;
        NSLog(@"CELL ID: %lu", (long)cell.ID);
    }
    
    if (!bookDetails.cellID == 0) {
        NSLog(@"cellID :%lu", (long)bookDetails.cellID);
        [self presentViewController:bookDetails animated:YES completion:nil];
    }
    
    if (self.collView != nil)
        [self.collView reloadData];
    
    [self.pickerView removeFromSuperview];
    [self.searchBar resignFirstResponder];
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
            [self setDataToDelete:self.favouriteCollectionView indexPath:indexPath tableName:@"favouriteBooks"];
            self.isEditMode = YES;
            [self.favouriteCollectionView reloadData];
        }
    } else if ([gestureRecognizer.view isEqual:self.customCollectionView]) {
        indexPath = [self.customCollectionView indexPathForItemAtPoint:p];
        if (indexPath != nil) {
            cell =[self.customCollectionView dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
            [self setDataToDelete:self.customCollectionView indexPath:indexPath tableName:[NSString stringWithFormat:@"%@Books", self.tableName]];
            self.isEditMode = YES;
            [self.customCollectionView reloadData];
        }
    }
    NSLog(@"getting cell %@", indexPath);
    
    
}

-(void)setDataToDelete:(BookCollectionView *)collView indexPath:(NSIndexPath *)indexPath tableName:(NSString *)tableName{
    
    self.collView = collView;
    self.indexPath = indexPath;
    self.collName = tableName;
    
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
        return self.appDelegate.favouriteBooks.count;
    } else if (collectionView == self.customCollectionView) {
        return self.appDelegate.customListBooks.count;
    }
    
    else return 0;
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    UIColor *customTitleColor = [UIColor blackColor];
    for (UIView *subview in actionSheet.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            
            [button setTitleColor:customTitleColor forState:UIControlStateHighlighted];
            [button setTitleColor:customTitleColor forState:UIControlStateNormal];
            [button setTitleColor:customTitleColor forState:UIControlStateSelected];
        }
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BookCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
    
    if ([indexPath isEqual:self.indexPath] && self.isEditMode && [collectionView isEqual:self.collView]) {
        
        UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"What would you like to do?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                @"Mark as Read",
                                @"Delete",
                                nil];
        popup.tag = 1;
        [popup showInView:[UIApplication sharedApplication].keyWindow];
        
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
            
        } else {
            
            
            NSURL *url = [NSURL URLWithString:bDB.coverLink];
            
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
                
                
                NSData *data = [NSData dataWithContentsOfURL:url];
                UIImage *bookImage = [[UIImage alloc] initWithData:data];
                
                dispatch_sync(dispatch_get_main_queue(), ^(void) {
                    
                    cell.bookImage.image = bookImage;
                });
                
                
                cell.ID = bDB.ID;
                
                NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                
                // If you go to the folder below, you will find those pictures
                NSLog(@"%@",docDir);
                
                NSLog(@"saving png");
                NSString *imageName = [NSString stringWithFormat:@"suggestedBooks%ld.png",(long)cell.ID];
                NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@",docDir, imageName];
                NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(bookImage)];
                [data1 writeToFile:pngFilePath atomically:YES];
                
            });
            
        }
        
    } else if (collectionView == self.favouriteCollectionView) {
        BooksDatabase *bDB = [self.appDelegate.favouriteBooks objectAtIndex:indexPath.row];
        
        //if image is stored then show it if not and there is internet connection load it and store it
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *imageName = [NSString stringWithFormat:@"favouriteBooks%ld.png",(long)bDB.ID];
        NSString* pngFilePath = [docDir stringByAppendingPathComponent:imageName];
        
        NSLog(@"%@", imageName);
        
        NSLog(@"%@", pngFilePath);
        
        if ([fileManager fileExistsAtPath:pngFilePath])
        {
            UIImage *bookImage = [[UIImage alloc] initWithContentsOfFile:pngFilePath];
            cell.bookImage.image = bookImage;
            cell.ID = bDB.ID;
            NSLog(@"loading from memory");
            
        } else {
            NSLog(@"need to save new book");
            
            NSURL *url = [NSURL URLWithString:bDB.coverLink];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
                NSData *data = [NSData dataWithContentsOfURL:url];
                UIImage *bookImage = [[UIImage alloc] initWithData:data];
                dispatch_sync(dispatch_get_main_queue(), ^(void) {
                    
                    cell.bookImage.image = bookImage;
                });
                
                
                cell.ID = bDB.ID;
                
                NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                
                // If you go to the folder below, you will find those pictures
                NSLog(@"%@",docDir);
                
                NSLog(@"saving png");
                NSString *imageName = [NSString stringWithFormat:@"favouriteBooks%ld.png",(long)cell.ID];
                NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@",docDir, imageName];
                NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(bookImage)];
                [data1 writeToFile:pngFilePath atomically:YES];
            });
            
        }
        
        
        NSLog(@"favourite collection view book images %lu", (unsigned long)self.favouriteCollectionView.bookImages.count);
        
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
        } else {
            
            NSURL *url = [NSURL URLWithString:bDB.coverLink];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
                NSData *data = [NSData dataWithContentsOfURL:url];
                UIImage *bookImage = [[UIImage alloc] initWithData:data];
                dispatch_sync(dispatch_get_main_queue(), ^(void) {
                    
                    cell.bookImage.image = bookImage;
                });
                
                
                cell.ID = bDB.ID;
                
                NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                
                // If you go to the folder below, you will find those pictures
                NSLog(@"%@",docDir);
                
                NSLog(@"saving png");
                NSString *imageName = [NSString stringWithFormat:@"%@Books%ld.png",self.tableName, (long)cell.ID];
                NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@",docDir, imageName];
                NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(bookImage)];
                [data1 writeToFile:pngFilePath atomically:YES];
                
            });
        }
        
    }
    return cell;
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    [self markBookAsRead];
                    break;
                case 1:
                    [self deleteCell];
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
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

//- (void)markBookAsRead:(UIButton *)sender {
- (void)markBookAsRead{
    NSLog(@"marked as read");
    if (self.indexPath != nil) {
        
        BookCollectionViewCell *cell;
        if ([self.collName rangeOfString:@"favourite" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            
            cell = (BookCollectionViewCell*)[self.favouriteCollectionView cellForItemAtIndexPath:self.indexPath];
            
        } else {
            cell = (BookCollectionViewCell*)[self.customCollectionView cellForItemAtIndexPath:self.indexPath];
        }
        
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        self.uniqueID  = self.uniqueID + 1;
        NSString *imageName = [NSString stringWithFormat:@"readBooks%ld.png", (long)self.uniqueID];;
        NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@",docDir, imageName];
        NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(cell.bookImage.image)];
        
        [data1 writeToFile:pngFilePath atomically:YES];
        
        NSString *imageN = [NSString stringWithFormat:@"%@%ld.png",self.collName,(long)cell.ID];
        
        NSLog(@"imageNAme %@", imageN);
        
        NSString* pngFilePathh = [NSString stringWithFormat:@"%@/%@",docDir, imageN];
        NSLog(@"filePath to removeFrom %@", pngFilePathh);
        [self.appDelegate moveBooksToReadInTheDatabase:self.collName ID:cell.ID indexPath:self.indexPath.row];
        [self.appDelegate deleteBooksToReadFromOriginalTableWithoutDeletingFromTable:self.collName ID:cell.ID indexPath:self.indexPath.row];
        
        [self removeImage:pngFilePathh];
    }
    
    [self showWithCustomView:@"The book was marked as read"];
    
    [self.collView reloadData];
    
    self.indexPath = nil;
    self.collView = nil;
    self.bookImages = nil;
    self.collName = nil;
    
}

//-(void)deleteCell:(UIButton *)sender {
-(void)deleteCell{
    NSLog(@"here to delete");
    
    if (self.indexPath != nil) {
        BookCollectionViewCell *cell;
        if ([self.collName rangeOfString:@"favourite" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            
            cell = (BookCollectionViewCell*)[self.favouriteCollectionView cellForItemAtIndexPath:self.indexPath];
            
        } else {
            cell = (BookCollectionViewCell*)[self.customCollectionView cellForItemAtIndexPath:self.indexPath];
        }
        
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *imageN = [NSString stringWithFormat:@"%@%ld.png",self.collName,(long)cell.ID];
        
        NSLog(@"imageNAme %@", imageN);
        
        NSString* pngFilePathh = [NSString stringWithFormat:@"%@/%@",docDir, imageN];
        NSLog(@"%@", pngFilePathh);
        [self.appDelegate deleteBooksToReadFromOriginalTable:self.collName ID:cell.ID indexPath:self.indexPath.row];
        [self removeImage:pngFilePathh];
    }
    
    [self showWithCustomView:@"The book was deleted"];
    
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

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSLog(@"You selected this: %@", [self.pickerViewData objectAtIndex: row]);
    
    if ([[self.pickerViewData objectAtIndex:row] isEqualToString:@"Create New List"]) {
        
        NSLog(@"here");
        
        self.av = [[UIAlertView alloc] initWithTitle:@"Create New List" message:@"Would you like to create a new list called?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
        
        [self.av setAlertViewStyle:UIAlertViewStylePlainTextInput];
        
        [self.av show];
        
    } else {
        [self.customListButton setTitle:[self.pickerViewData objectAtIndex:row] forState:UIControlStateNormal];
        
        [self loadCustomListDatabaseAndRefreshView:[self.pickerViewData objectAtIndex:row]];
        
        NSLog(@"changed to %@", [self.pickerViewData objectAtIndex:row]);
        
    }
    
    [self.customCollectionView reloadData];
    
    [self.pickerView removeFromSuperview];
    
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0)
    {
        NSLog(@"You have clicked No");
    }
    else if(buttonIndex == 1)
    {
        NSLog(@"You have clicked Yes with listName %@", [[self.av textFieldAtIndex:0] text]);
        self.customListTitle = [[self.av textFieldAtIndex:0] text];
        
        self.customListTitle = [self.customListTitle stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        
        NSLog(@"%@", self.customListTitle);
        
        [self.appDelegate createNewCustomListInTheDatabase:self.customListTitle];
        [self.customListButton setTitle:[self.customListTitle capitalizedString] forState:UIControlStateNormal];
        [self loadCustomListDatabaseAndRefreshView:self.customListTitle];
        [self initiatePickerViewWithTableNames];
    }
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

- (IBAction)showQRReader:(id)sender {
    
    
    if ([self.appDelegate connectedToInternet]) {
    
        BarcodeScannerViewController *barcodeScanner = [[BarcodeScannerViewController alloc] initWithNibName:nil bundle:nil];
    
        [self presentViewController:barcodeScanner animated:NO completion:nil];
        
    } else {
        [self showWithCustomView:@"No Internet Connection"];
    }
    
}

- (IBAction)showMenu:(id)sender {
    
    NSLog(@"in side menu here");
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
    
}


@end
