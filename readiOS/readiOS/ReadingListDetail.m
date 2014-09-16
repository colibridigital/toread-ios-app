//
//  ReadingListDetail.m
//  readiOS
//
//  Created by Ingrid Funie on 23/07/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import "ReadingListDetail.h"
#import "BookCollectionViewCell.h"
#import "BooksDatabase.h"
#import "BookDetailsViewController.h"

@interface ReadingListDetail ()

@end

@implementation ReadingListDetail

@synthesize tableName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"show view");
    
    self.listTitle.text = [[self.tableName stringByReplacingOccurrencesOfString:@"Books" withString:@""] capitalizedString];
    
    [self getBooks];
    [self.collectionView registerNibAndCell];
    [self addGestureRecognizer:self.collectionView];
    [self.collectionView flashScrollIndicators];
    [self.collectionView reloadData];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:YES];
    
    self.listTitle.text = [[self.tableName stringByReplacingOccurrencesOfString:@"Books" withString:@""] capitalizedString];
    
    [self getBooks];
    [self.collectionView reloadData];
}

- (IBAction) dismissView:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)getBooks {
    self.books = nil;
    
    NSMutableArray *booksArray = [[NSMutableArray alloc] init];
    self.books = booksArray;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"books.sqlite"];
    
    NSLog(@"path %@", path);
    //Open the db. The db was prepared outside the application
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        //Get the primary key for all the books
        
        const char *sql = [[NSString stringWithFormat:@"SELECT ID FROM %@", self.tableName] UTF8String];
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
                BooksDatabase *bDB = [[BooksDatabase alloc]initWithPrimaryKey:ID database:database table:self.tableName];
                
                [self.books addObject:bDB];
                
                /*NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSString *imageName = [NSString stringWithFormat:@"books%ld.png",(long)bDB.ID];
                
                NSString* pngFilePath = [docDir stringByAppendingPathComponent:imageName];
                
                [self.booksImages addObject:pngFilePath];*/
                
            }
        }
        NSLog(@"Number of items from the DB: %lu", (unsigned long)self.books.count);
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
    
    bookDetails.tableName = self.tableName;
    bookDetails.cellID = cell.ID;
    
    if (!bookDetails.cellID == 0) {
        NSLog(@"cellID :%lu", (long)bookDetails.cellID);
        [self presentViewController:bookDetails animated:YES completion:nil];
    }
    
}


#pragma mark - Collection View Data Sources

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"books count %li", (unsigned long)self.books.count);
    return self.books.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BookCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
    
    BooksDatabase *bDB = [self.books objectAtIndex:indexPath.row];
    //get the image from the already existent one as we have the ID...
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *imageName = [NSString stringWithFormat:@"%@%ld.png",self.tableName,(long)bDB.ID];
    NSString* pngFilePath = [docDir stringByAppendingPathComponent:imageName];
    
    if ([fileManager fileExistsAtPath:pngFilePath]) {
        cell.bookImage.image = [[UIImage alloc] initWithContentsOfFile:pngFilePath];
        cell.ID = bDB.ID;
    } else {
        NSURL *url = [NSURL URLWithString:bDB.coverLink];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
            UIImage *bookImage;
            
            @try {
                NSData *data = [NSData dataWithContentsOfURL:url];
                bookImage = [[UIImage alloc] initWithData:data];
                
                dispatch_sync(dispatch_get_main_queue(), ^(void) {
                    
                    cell.bookImage.image = bookImage;
                });
            }
            @catch (NSException * e) {
                NSLog(@"Exception: %@", e);
            }
            
            cell.ID = bDB.ID;
            
            NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            NSString *imageName = [NSString stringWithFormat:@"%@%ld.png",self.tableName, (long)cell.ID];
            NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@",docDir, imageName];
            NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(bookImage)];
            
            if (data1 != nil) {
                [data1 writeToFile:pngFilePath atomically:YES];
            }
            
        });

    }
    
    
    
    return cell;
}


@end
