//
//  AppDelegate.h
//  readiOS
//
//  Created by Ingrid Funie on 04/01/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    sqlite3 *database;
    NSMutableArray *suggestedBooks;
    NSMutableArray *favouriteBooks;
    NSMutableArray *customListBooks;
    NSMutableArray *tableNames;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) NSMutableArray *suggestedBooks;
@property (nonatomic, retain) NSMutableArray *favouriteBooks;
@property (nonatomic, retain) NSMutableArray *customListBooks;
@property (nonatomic, retain) NSMutableArray *tableNames;

- (void)moveBooksToReadInTheDatabase:(NSString *)tableName ID:(NSInteger)ID indexPath:(NSInteger)indexPath;

- (void)initiateCustomBooksListFromTheDatabase:(NSString *)tableName;

- (void)deleteBooksToReadFromOriginalTable:(NSString *)tableName ID:(NSInteger)ID indexPath:(NSInteger)indexPath;

- (void)deleteBooksToReadFromOriginalTableWithoutDeletingFromTable:(NSString *)tableName ID:(NSInteger)ID indexPath:(NSInteger)indexPath;

- (void)setupMenu:(UIViewController *)mainViewController;

- (void)getAllDatabaseTableNames;

- (void)createNewCustomListInTheDatabase:(NSString *)name;

- (void)addBookToTheDatabaseBookList:(NSString *)tableName bookTitle:(NSString *)bookTitle bookAuthors:(NSString *)bookAuthors publisher:(NSString *)publisher coverLink:(NSString *)coverLink rating:(double )rating;

-(int)getNumberOfReadBooksFromDB;

-(void)loadFavouriteDatabase;

@end
