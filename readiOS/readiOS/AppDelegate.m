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
- (void)initializeDatabase;

@end

@implementation AppDelegate

@synthesize suggestedBooks;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self createEditableCopyOfDatabaseIfNeeded];
    [self initializeDatabase];
    
    
    // Override point for customization after application launch.
    SideMenuViewController *leftMenuViewController = [[SideMenuViewController alloc] init];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                             bundle: nil];
    
    ViewController *mainViewController = (ViewController*)[mainStoryboard
                                                                   instantiateViewControllerWithIdentifier: @"MainViewController"];
    
    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController
                                                    containerWithCenterViewController:mainViewController
                                                    leftMenuViewController:leftMenuViewController
                                                    rightMenuViewController:nil];
    self.window.rootViewController = container;
    [self.window makeKeyAndVisible];
    return YES;
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

//open the db connection and retrieve minimal information for all objects
- (void)initializeDatabase {
    
    NSMutableArray *suggestedBooksArray = [[NSMutableArray alloc] init];
    self.suggestedBooks = suggestedBooksArray;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"books.sqlite"];
    
    NSLog(@"path %@", path);
    //Open the db. The db was prepared outside the application
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        //Get the primary key for all the books
        
        //mock here the tableName (bookList)
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
        NSLog(@"Number of items from the DB: %lu", (unsigned long)suggestedBooks.count);
        // finalize the statement
        sqlite3_finalize(statement);
        sqlite3_close(database);
    } else {
        //even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open DB with message '%s' .", sqlite3_errmsg(database));
    }
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
