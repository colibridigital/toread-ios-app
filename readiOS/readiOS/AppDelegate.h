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
    NSString* userName;
    NSString* pass;
    BOOL isLogin;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) NSMutableArray *suggestedBooks;
@property (nonatomic, retain) NSMutableArray *favouriteBooks;
@property (nonatomic, retain) NSMutableArray *customListBooks;
@property (nonatomic, retain) NSMutableArray *tableNames;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *pass;
@property (nonatomic) BOOL isLogin;

- (void)moveBooksToReadInTheDatabase:(NSString *)tableName ID:(NSInteger)ID indexPath:(NSInteger)indexPath;

- (void)initiateCustomBooksListFromTheDatabase:(NSString *)tableName;
- (void)initiateCustomBooksListFromTheDatabaseWithAllDetails:(NSString *)tableName;

- (void)deleteBooksToReadFromOriginalTable:(NSString *)tableName ID:(NSInteger)ID indexPath:(NSInteger)indexPath;

- (void)deleteBooksToReadFromOriginalTableWithoutDeletingFromTable:(NSString *)tableName ID:(NSInteger)ID indexPath:(NSInteger)indexPath;

- (void)setupMenu:(UIViewController *)mainViewController;

- (void)getAllDatabaseTableNames;

- (BOOL)connectedToInternet;

- (void)createNewCustomListInTheDatabase:(NSString *)name;

- (void)addBookToTheDatabaseBookList:(NSString *)tableName bookTitle:(NSString *)bookTitle bookAuthors:(NSString *)bookAuthors publisher:(NSString *)publisher coverLink:(NSString *)coverLink rating:(double )rating isbn:(NSString*)isbn desc:(NSString*)desc;

- (NSString*)login:(NSString*)username password:(NSString*)password;

- (void)doTheDatabaseSetup;

-(int)getNumberOfReadBooksFromDB;
- (void)deleteTableFromDatabase:(NSString *)tableName;

-(void)loadFavouriteDatabase;
- (void)loadFavouriteDatabaseAllDetails;
- (void)initializeSuggestedBooksDatabase;

- (UIStoryboard *)setStoryboard;

- (void) displayTutorial;

- (NSString*)registerUser:(NSString*)username password:(NSString*)password firstName:(NSString*)firstName
                 lastName:(NSString*)lastName emailAddress:(NSString*)emailAddress ageRange:(NSString*)ageRange
                      sex:(NSString*)sex occupation:(NSString*)occupation;


@end
