//
//  AppDelegate.m
//  readiOS
//
//  Created by Ingrid Funie on 04/01/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import "AppDelegate.h"
#import "MFSideMenu.h"
#import "ViewController.h"
#import "SideMenuViewController.h"
#import "BooksDatabase.h"


@interface AppDelegate (Private)

- (void)createEditableCopyOfDatabaseIfNeeded;
- (void)initializeSuggestedBooksDatabase;

@end

@implementation AppDelegate

@synthesize suggestedBooks,favouriteBooks,customListBooks, tableNames;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"hasAuthenticated"])
        [self authenticateWithServer];
    
    [self createEditableCopyOfDatabaseIfNeeded];
   
    
    //i should do this only once a day or smt and ofcourse only if the internet is working
    [self performSingleAuthentication];
    
    UIStoryboard *mainStoryboard;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        
        mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPad"
                                                   bundle: nil];
    } else {
        
        
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        
        if (iOSDeviceScreenSize.height == 480)
        {   // iPhone 3GS, 4, and 4S and iPod Touch 3rd and 4th generation: 3.5 inch screen (diagonally measured)
            
            // Instantiate a new storyboard object using the storyboard file named Storyboard_iPhone35
            mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone3" bundle:nil];
        } else {
        
            mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                   bundle: nil];
        }
    }
    
    
    ViewController *mainViewController = (ViewController*)[mainStoryboard
                                                           instantiateViewControllerWithIdentifier: @"MainViewController"];
    
    [self setupMenu:mainViewController];
    return YES;
}

- (void)authenticateWithServer {
    NSMutableDictionary *json= [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *deviceDetails= [[NSMutableDictionary alloc] init];
    
    //UIDevice *device = [UIDevice currentDevice];
    
    //NSString *deviceOSId = [[device identifierForVendor]UUIDString];
    
    //NSString *device_model = [device model];
    
    NSLog(@"authenticating again");
    
    NSString *deviceOSId = @"2709";
    
    NSString *device_model = @"Simulator";
    
    
    [deviceDetails setObject:deviceOSId forKey:@"deviceOSId"];
    [deviceDetails setObject:@"Apple" forKey:@"device_make"];
    [deviceDetails setObject:device_model forKey:@"device_model"];
    [deviceDetails setObject:@"iOS" forKey:@"platform"];
    [json setObject:deviceDetails forKey:@"device"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@", jsonString);
    
    //perform post
    
    //http://86.132.218.95:2709
    //http://jamescross91.no-ip.biz:2709
    
    NSURL *url = [NSURL URLWithString:@"http://jamescross91.no-ip.biz:2709/api/initdevice"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLResponse *response;
    NSError *err;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    [self parseResponse:responseData];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasAuthenticated"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)performSingleAuthentication {
        NSMutableDictionary *json= [[NSMutableDictionary alloc] init];
        
        NSMutableDictionary *authDetails= [[NSMutableDictionary alloc] init];
        
        [authDetails setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_name"] forKey:@"username"];
        [authDetails setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"auth_token"] forKey:@"token"];
        [authDetails setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceID"] forKey:@"device_id"];
        [json setObject:authDetails forKey:@"auth_data"];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@", jsonString);
        
        //perform post
        NSURL *url = [NSURL URLWithString:@"http://jamescross91.no-ip.biz:2709/api/suggest/bestsell"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
        NSURLResponse *response;
        NSError *err;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
        
    [self requestSuggestedBooksAndAddThemToTheDatabase:responseData];
    
}

- (void) parseResponse:(NSData*)jsonResponseData {
    
    NSError *error;
    
    NSLog(@"%@", [[NSString alloc] initWithData:jsonResponseData encoding:NSUTF8StringEncoding]);
    
    NSDictionary* jsonResponseDict = [NSJSONSerialization
                            JSONObjectWithData:jsonResponseData
                            options:0
                            error:&error];
    
    NSLog(@"dict %@", jsonResponseDict);
    
    NSString *userName = [jsonResponseDict objectForKey:@"user_name"];
    NSString *authToken = [[jsonResponseDict objectForKey:@"devices"][0] objectForKey:@"auth_token"];
    NSString *deviceID = [[jsonResponseDict objectForKey:@"devices"][0] objectForKey:@"tr_device_id"];
    
    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:@"user_name"];
    [[NSUserDefaults standardUserDefaults] setObject:authToken forKey:@"auth_token"];
    [[NSUserDefaults standardUserDefaults] setObject:deviceID forKey:@"deviceID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //NSLog(@"USER %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"user_name"]);
    
}

- (void)setupMenu:(UIViewController *)mainViewController {
    SideMenuViewController *leftMenuViewController = [[SideMenuViewController alloc] init];
    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController
                                                    containerWithCenterViewController:mainViewController
                                                    leftMenuViewController:leftMenuViewController
                                                    rightMenuViewController:nil];
    self.window.rootViewController = container;
    [self.window makeKeyAndVisible];
    
}

- (void)createEditableCopyOfDatabaseIfNeeded {
    //test for existence
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"books.sqlite"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) return;
    //the writable db does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"books.sqlite"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@' .", [error localizedDescription]);
    }
}

- (void)requestSuggestedBooksAndAddThemToTheDatabase:(NSData*)jsonResponseData {
    [self createNewCustomListInTheDatabase:@"suggested"];
    
    NSError *error;
    
    NSLog(@"%@", [[NSString alloc] initWithData:jsonResponseData encoding:NSUTF8StringEncoding]);
    
    NSDictionary* jsonResponseDict = [NSJSONSerialization
                                      JSONObjectWithData:jsonResponseData
                                      options:0
                                      error:&error];
    
    NSLog(@"dict %@", jsonResponseDict);

    NSArray *items = [jsonResponseDict objectForKey:@"best_sellers"];
    
    for (int i=0; i < [items count]; i++) {
        NSString *title = [items[i] objectForKey:@"title"];
        
        NSString* authors = @"";
        
        NSArray *authorsArray = [items[i] objectForKey:@"authors"];
            
            NSLog(@" authors %@", authorsArray);
            
            for (NSDictionary* author in authorsArray) {
                
                authors = [authors stringByAppendingString:[NSString stringWithFormat:@"%@; ",[author objectForKey:@"Name"]]];
            }
            
            authors = [authors substringToIndex:[authors length] - 2];

        NSString *coverLink = [items[i] objectForKey:@"cover_url"];
        NSString *isbn = [items[i] objectForKey:@"ISBN"];
        
        double rating = 0.0;
        NSString* publisher = @"";
        NSString* desc = @"";
        
        
        [self addBookToTheDatabaseBookList:@"suggested" bookTitle:title bookAuthors:authors publisher:publisher coverLink:coverLink rating:rating isbn:isbn desc:desc];
        NSLog(@"ADDED");

    }
    
    NSLog(@"INITIALIZE SUGGESTED");
    //[self initializeSuggestedBooksDatabase];
}

//open the db connection and retrieve minimal information for all objects
- (void)initializeSuggestedBooksDatabase {
    self.suggestedBooks = nil;
    
    NSMutableArray *suggestedBooksArray = [[NSMutableArray alloc] init];
    self.suggestedBooks = suggestedBooksArray;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"books.sqlite"];
    
    NSLog(@"path %@", path);
    //Open the db. The db was prepared outside the application
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        //Get the primary key for all the books

        NSString *tableName = @"suggestedBooks";
        
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
                [suggestedBooks addObject:bDB];
            }
        }
        NSLog(@"Number of SUGGESTED from the DB: %lu", (unsigned long)suggestedBooks.count);
        // finalize the statement
        sqlite3_finalize(statement);
        sqlite3_close(database);
    } else {
        //even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open DB with message '%s' .", sqlite3_errmsg(database));
    }
    
}

- (void)createNewCustomListInTheDatabase:(NSString *)name {
    
    NSString* tableName = [name lowercaseString];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"books.sqlite"];
    
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        //Get the primary key for all the books
        
        const char *sql = [[NSString stringWithFormat:@"create table if not exists %@Books (ID INTEGER PRIMARY KEY, TITLE VARCHAR(300), AUTHORS VARCHAR(300), EDITOR VARCHAR(300), COVERLINK VARCHAR(300), DUEDATE VARCHAR(50), RATING REAL DEFAULT 0, ISBN VARCHAR(30) UNIQUE, DESC VARCHAR(4096))", tableName] UTF8String];
        NSLog(@"%s",sql);
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
            // We step through the results once for each row.
            NSLog(@"in sql results app delegate");
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                NSLog(@"in SQL");
                int ID = sqlite3_column_int(statement, 0);
                NSLog(@"ID is %i", ID);
                
                NSLog(@"DONE");
            }
        }
        // finalize the statement
        sqlite3_finalize(statement);
        sqlite3_close(database);
    } else {
        //even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open DB with message '%s' .", sqlite3_errmsg(database));
    }
    
    
}

- (void)getAllDatabaseTableNames {
    
    NSMutableArray *tableNamesArray = [[NSMutableArray alloc] init];
    self.tableNames = tableNamesArray;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"books.sqlite"];
    
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        //Get the primary key for all the books
        
        const char *sql = [[NSString stringWithFormat:@"select name from sqlite_master where type='table'"] UTF8String];
        NSLog(@"%s",sql);
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
            // We step through the results once for each row.
            NSLog(@"in sql results app delegate");
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                NSLog(@"in SQL");
                int ID = sqlite3_column_int(statement, 0);
                NSLog(@"ID is %i", ID);
                
                [tableNames addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)]];
                
                NSLog(@"DONE");
            }
        }
        NSLog(@"Number of TABLES from the DB: %lu", (unsigned long)tableNames.count);
        // finalize the statement
        sqlite3_finalize(statement);
        sqlite3_close(database);
    } else {
        //even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open DB with message '%s' .", sqlite3_errmsg(database));
    }
    
    
}

- (void)initiateCustomBooksListFromTheDatabase:(NSString *)tableName {
    
    self.customListBooks = nil;
    
    NSMutableArray *customListBooksArray = [[NSMutableArray alloc] init];
    self.customListBooks = customListBooksArray;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"books.sqlite"];
    
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        //Get the primary key for all the books
        
        const char *sql = [[NSString stringWithFormat:@"SELECT ID FROM %@", tableName] UTF8String];
        NSLog(@"%s",sql);
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
            // We step through the results once for each row.
            NSLog(@"in sql results app delegate");
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                NSLog(@"in SQL");
                int ID = sqlite3_column_int(statement, 0);
                NSLog(@"ID is %i", ID);
                BooksDatabase *bDB = [[BooksDatabase alloc]initWithPrimaryKey:ID database:database table:tableName];
                [customListBooks addObject:bDB];
            }
        }
        NSLog(@"Number of items from the DB: %lu", (unsigned long)customListBooks.count);
        // finalize the statement
        sqlite3_finalize(statement);
        sqlite3_close(database);
    } else {
        //even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open DB with message '%s' .", sqlite3_errmsg(database));
    }
    
}

- (void)initiateCustomBooksListFromTheDatabaseWithAllDetails:(NSString *)tableName {
    
    self.customListBooks = nil;
    
    NSMutableArray *customListBooksArray = [[NSMutableArray alloc] init];
    self.customListBooks = customListBooksArray;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"books.sqlite"];
    
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        //Get the primary key for all the books
        
        const char *sql = [[NSString stringWithFormat:@"SELECT ID FROM %@", tableName] UTF8String];
        NSLog(@"%s",sql);
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
            // We step through the results once for each row.
            NSLog(@"in sql results app delegate");
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                NSLog(@"in SQL");
                int ID = sqlite3_column_int(statement, 0);
                NSLog(@"ID is %i", ID);
                BooksDatabase *bDB = [[BooksDatabase alloc]initWithPrimaryKeyAllDetails:ID database:database table:tableName];
                [customListBooks addObject:bDB];
            }
        }
        NSLog(@"Number of items from the DB: %lu", (unsigned long)customListBooks.count);
        // finalize the statement
        sqlite3_finalize(statement);
        sqlite3_close(database);
    } else {
        //even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open DB with message '%s' .", sqlite3_errmsg(database));
    }
    
}


- (void)loadFavouriteDatabase {
    
    self.favouriteBooks = nil;
    
    NSMutableArray *favouriteListBooksArray = [[NSMutableArray alloc] init];
    self.favouriteBooks = favouriteListBooksArray;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"books.sqlite"];
    
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        //Get the primary key for all the books
        
        const char *sql = [[NSString stringWithFormat:@"SELECT ID FROM %@", @"favouriteBooks"] UTF8String];
        NSLog(@"%s",sql);
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
            // We step through the results once for each row.
            NSLog(@"in sql results app delegate");
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                NSLog(@"in SQL");
                int ID = sqlite3_column_int(statement, 0);
                NSLog(@"ID is %i", ID);
                BooksDatabase *bDB = [[BooksDatabase alloc]initWithPrimaryKey:ID database:database table:@"favouriteBooks"];
                [favouriteBooks addObject:bDB];
            }
        }
        NSLog(@"Number of items from the DB: %lu", (unsigned long)favouriteBooks.count);
        // finalize the statement
        sqlite3_finalize(statement);
        sqlite3_close(database);
    } else {
        //even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open DB with message '%s' .", sqlite3_errmsg(database));
    }
    
}


- (void)loadFavouriteDatabaseAllDetails {
    
    self.favouriteBooks = nil;
    
    NSMutableArray *favouriteListBooksArray = [[NSMutableArray alloc] init];
    self.favouriteBooks = favouriteListBooksArray;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"books.sqlite"];
    
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        //Get the primary key for all the books
        
        const char *sql = [[NSString stringWithFormat:@"SELECT ID FROM %@", @"favouriteBooks"] UTF8String];
        NSLog(@"%s",sql);
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
            // We step through the results once for each row.
            NSLog(@"in sql results app delegate");
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                NSLog(@"in SQL");
                int ID = sqlite3_column_int(statement, 0);
                NSLog(@"ID is %i", ID);
                BooksDatabase *bDB = [[BooksDatabase alloc]initWithPrimaryKeyAllDetails:ID database:database table:@"favouriteBooks"];
                [favouriteBooks addObject:bDB];
            }
        }
        NSLog(@"Number of items from the DB: %lu", (unsigned long)favouriteBooks.count);
        // finalize the statement
        sqlite3_finalize(statement);
        sqlite3_close(database);
    } else {
        //even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open DB with message '%s' .", sqlite3_errmsg(database));
    }
    
}



- (void)moveBooksToReadInTheDatabase:(NSString *)tableName ID:(NSInteger)ID indexPath:(NSInteger)indexPath{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"books.sqlite"];
    
    NSLog(@"path %@", path);
    //Open the db. The db was prepared outside the application
    
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        const char *sql = [[NSString stringWithFormat:@"INSERT INTO readBooks(TITLE, AUTHORS, EDITOR, COVERLINK, DUEDATE, RATING, ISBN, DESC) SELECT TITLE, AUTHORS, EDITOR, COVERLINK, DUEDATE, RATING, ISBN, DESC FROM %@ WHERE ID = %lu ", tableName, (unsigned long)ID] UTF8String];
        NSLog(@"%s",sql);
        
        if ([tableName rangeOfString:@"favourite" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            
            if (indexPath < self.favouriteBooks.count && self.favouriteBooks.count !=0) {
                [self.favouriteBooks removeObjectAtIndex:indexPath];
            }
        } else {
            if (indexPath < self.customListBooks.count && self.customListBooks.count !=0)
                [self.customListBooks removeObjectAtIndex:indexPath];
        }
        
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
            if (sqlite3_step(statement) != SQLITE_DONE)
                return;
        }
        
        // finalize the statement
        sqlite3_finalize(statement);
        sqlite3_close(database);
    } else {
        //even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open DB with message '%s' .", sqlite3_errmsg(database));
    }
    
}

- (void)deleteBooksToReadFromOriginalTableWithoutDeletingFromTable:(NSString *)tableName ID:(NSInteger)ID indexPath:(NSInteger)indexPath{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"books.sqlite"];
    
    NSLog(@"path %@", path);
    //Open the db. The db was prepared outside the application
    
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        const char *sql = [[NSString stringWithFormat:@"DELETE FROM %@ WHERE ID = %lu", tableName, (unsigned long)ID] UTF8String];
        NSLog(@"%s",sql);
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
            if (sqlite3_step(statement) != SQLITE_DONE)
                return;
        }
        
        // finalize the statement
        sqlite3_finalize(statement);
        sqlite3_close(database);
    } else {
        //even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open DB with message '%s' .", sqlite3_errmsg(database));
    }
    
}


- (void)deleteBooksToReadFromOriginalTable:(NSString *)tableName ID:(NSInteger)ID indexPath:(NSInteger)indexPath{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"books.sqlite"];
    
    NSLog(@"path %@", path);
    //Open the db. The db was prepared outside the application
    
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        const char *sql = [[NSString stringWithFormat:@"DELETE FROM %@ WHERE ID = %lu", tableName, (unsigned long)ID] UTF8String];
        NSLog(@"%s",sql);
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
            if (sqlite3_step(statement) != SQLITE_DONE)
                return;
        }
        if ([tableName rangeOfString:@"favourite" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                if (indexPath < self.favouriteBooks.count && self.favouriteBooks.count !=0) {
                    [self.favouriteBooks removeObjectAtIndex:indexPath];
                }
        } else {
                if (indexPath < self.customListBooks.count && self.customListBooks.count != 0)
                    [self.customListBooks removeObjectAtIndex:indexPath];
        }
      
        
        // finalize the statement
        sqlite3_finalize(statement);
        sqlite3_close(database);
    } else {
        //even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open DB with message '%s' .", sqlite3_errmsg(database));
    }
    
}

- (void)addBookToTheDatabaseBookList:(NSString *)tableName bookTitle:(NSString *)bookTitle bookAuthors:(NSString *)bookAuthors publisher:(NSString *)publisher coverLink:(NSString *)coverLink rating:(double )rating isbn:(NSString*)isbn desc:(NSString*)desc {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"books.sqlite"];
    
    NSLog(@"path %@", path);
    //Open the db. The db was prepared outside the application
    
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        const char *sql = [[NSString stringWithFormat:@"INSERT INTO %@Books (TITLE,AUTHORS,EDITOR,COVERLINK,DUEDATE,RATING,ISBN,DESC) VALUES('%@','%@','%@','%@','',%f, '%@', '%@')", tableName, bookTitle, bookAuthors, publisher, coverLink, rating, isbn, desc] UTF8String];
        NSLog(@"%s",sql);
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
            if (sqlite3_step(statement) != SQLITE_DONE)
                return;
        }
        // finalize the statement
        sqlite3_finalize(statement);
        sqlite3_close(database);
    } else {
        //even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open DB with message '%s' .", sqlite3_errmsg(database));
    }
    
    
}

- (int)getNumberOfReadBooksFromDB {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"books.sqlite"];
    
    int readBooksNB = 0;
    
    NSLog(@"path %@", path);
    //Open the db. The db was prepared outside the application
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        const char *sql = [[NSString stringWithFormat:@"SELECT COUNT(*) from readBooks"] UTF8String];
        NSLog(@"%s",sql);
        sqlite3_stmt *statement;
        
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
            
            // THIS IS WHERE IT FAILS:
            
            if (sqlite3_step(statement) == SQLITE_ERROR) {
                NSAssert1(0,@"Error when counting rows  %s",sqlite3_errmsg(database));
            } else {
                readBooksNB = sqlite3_column_int(statement, 0);
                NSLog(@"SQLite Rows: %i", readBooksNB);
            }
            sqlite3_finalize(statement);
        }
        
        sqlite3_close(database);
        
    }     else {
        //even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open DB with message '%s' .", sqlite3_errmsg(database));
    }
    
    return readBooksNB;
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
