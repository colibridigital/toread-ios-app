//
//  ReadBooksViewController.m
//  readiOS
//
//  Created by Ingrid Funie on 29/04/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import "ReadBooksViewController.h"
#import "BookCollectionViewCell.h"
#import "BooksDatabase.h"
#import "BookDetailsViewController.h"
#import "MFSideMenu.h"
#import "SideMenuViewController.h"

@interface ReadBooksViewController ()

@end

@implementation ReadBooksViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.booksImages = [@[] mutableCopy];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"show view");
    [self.collectionView registerNibAndCell];
    [self showReadBooks];
    [self addGestureRecognizer:self.collectionView];

}

- (IBAction) dismissView:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)showReadBooks {
    NSMutableArray *readBooksArray = [[NSMutableArray alloc] init];
    self.readBooks = readBooksArray;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"books.sqlite"];
    
    NSLog(@"path %@", path);
    //Open the db. The db was prepared outside the application
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        //Get the primary key for all the books
        
        NSString *tableName = @"readBooks";
        
        const char *sql = [[NSString stringWithFormat:@"SELECT ID FROM %@", tableName] UTF8String];
        NSLog(@"%s",sql);
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
            // We step through the results once for each row.
            NSLog(@"in sql results app delegate");
            NSLog(@"sqlite row : %d", SQLITE_ROW);
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                NSLog(@"in SQL");
                int ID = sqlite3_column_int(statement, 0);
                NSLog(@"ID is %i", ID);
                BooksDatabase *bDB = [[BooksDatabase alloc]initWithPrimaryKey:ID database:database table:tableName];
                [self.readBooks addObject:bDB];
            }
        }
        NSLog(@"Number of items from the DB: %lu", (unsigned long)self.readBooks.count);
        // finalize the statement
        sqlite3_finalize(statement);
        sqlite3_close(database);
    } else {
        //even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open DB with message '%s' .", sqlite3_errmsg(database));
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addGestureRecognizer:(BookCollectionView *)collView{
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tgr.delegate = self;
    [collView addGestureRecognizer:tgr];
}

-(void)handleTap:(UITapGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    CGPoint p = [gestureRecognizer locationInView:gestureRecognizer.view];
    
    BookDetailsViewController *bookDetails = [[BookDetailsViewController alloc] initWithNibName:@"BookDetailsViewController" bundle:nil];
    
    bookDetails.indexPath = [self.collectionView indexPathForItemAtPoint:p];
    BookCollectionViewCell* cell = (BookCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:bookDetails.indexPath];
    
    bookDetails.tableName = @"readBooks";
    bookDetails.bookImages = self.booksImages;
    bookDetails.cellID = cell.ID;
    
    
    [self presentViewController:bookDetails animated:YES completion:nil];
}


#pragma mark - Collection View Data Sources

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.readBooks.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BookCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
    
    BooksDatabase *bDB = [self.readBooks objectAtIndex:indexPath.row];
    NSURL *url = [NSURL URLWithString:bDB.coverLink];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *bookImage = [[UIImage alloc] initWithData:data]; //i can add this image to an array so i have it in memory all the time; or I can add it to the same book once downloaded and keep it there
    cell.bookImage.image = bookImage;
    
    cell.ID = bDB.ID;
    
    [self.booksImages addObject:data];
    
    [cell.deleteButton setEnabled:NO];
    [cell.readButton setEnabled:NO];
    [cell.deleteButton setHidden:YES];
    [cell.readButton setHidden:YES];
    
    return cell;
}


@end