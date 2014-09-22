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
#import "TutorialViewController.h"
#import "TutorialOptionViewController.h"


@interface AppDelegate (Private)

- (void)createEditableCopyOfDatabaseIfNeeded;
- (void)initializeSuggestedBooksDatabase;

@end

@implementation AppDelegate

@synthesize suggestedBooks,favouriteBooks,customListBooks, tableNames, userName, pass, isLogin;

- (UIStoryboard *)setStoryboard
{
    UIStoryboard *mainStoryboard;
    //when i ll do ipad
   /* if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        
        mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPad"
                                                   bundle: nil];
    } else {*/
        
        
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        
        if (iOSDeviceScreenSize.height == 480)
        {   // iPhone 3GS, 4, and 4S and iPod Touch 3rd and 4th generation: 3.5 inch screen (diagonally measured)
            
            // Instantiate a new storyboard object using the storyboard file named Storyboard_iPhone35
            mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone3" bundle:nil];
        } else {
            
            mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                       bundle: nil];
        }
    //}
    return mainStoryboard;
}

- (void)doTheDatabaseSetup
{
    
    [self createEditableCopyOfDatabaseIfNeeded];
    
}

- (void)authenticateAndSyncRegularly{

    if ([self connectedToInternet] && [[NSUserDefaults standardUserDefaults] boolForKey:@"hasAuthenticated"]) {
 
        NSString *jsonResponse = [self performSingleAuthentication];
        
        if([self howManyDaysHavePast:[[NSUserDefaults standardUserDefaults] valueForKey:@"lastUpdated"] today:[NSDate date]]>=7) {
            NSLog(@"i need to request suggested books again");
            [self requestSuggestedBooksAndAddThemToTheDatabase:jsonResponse];
        } else {
            NSLog(@"I do not need to request the suggested books again");
        }
       // NSLog(@"syncing with the server");
        NSString *jsonString = [self performSyncRequest];
        NSLog(@"response: %@", jsonString);
        [self syncWithTheServer:jsonString];
        
    }
}

- (void)requestBooksAndCreateDatabaseEntries {
    //NSLog(@"in creating the lists after login");
    
    [self createEditableCopyOfDatabaseIfNeeded];
    
    if ([self connectedToInternet] && [[NSUserDefaults standardUserDefaults] boolForKey:@"hasAuthenticated"]) {
        
        //NSLog(@"starting the setup");
        
        NSString *jsonResponse = [self performSingleAuthentication];
        
        [self requestSuggestedBooksAndAddThemToTheDatabase:jsonResponse];
        //NSLog(@"syncing with the server");
        [self getAllBooksFromServerAndCreateDatabase];
        
    }
    
    
}

- (void)getAllBooksFromServerAndCreateDatabase {
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
    
    //NSLog(@"%@", jsonString);
    
    NSURL *url = [NSURL URLWithString:@"http://toread.gocolibri.com:2709/api/sync/getall"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLResponse *response;
    NSError *err;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    jsonString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    NSLog(@"response from the server with BOOKS %@", jsonString);
    
    [self createDatabaseEntries:responseData];
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenTutorial"]) {
       // NSLog(@"i need to show the tutorial");
        [self displayTutorial];
        
    } else if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasAuthenticated"]) {
        
        [self registerOrLogin];
        
    } else {

        /*if ([self connectedToInternet]) {

            [self authenticateAndSyncRegularly];
            
        } else {*/
        
            UIStoryboard *mainStoryboard;
            
            mainStoryboard = [self setStoryboard];
            
            
            ViewController *mainViewController = (ViewController*)[mainStoryboard
                                                                   instantiateViewControllerWithIdentifier: @"MainViewController"];
            
            [self setupMenu:mainViewController];
            
        //}
        
    }
    
    return YES;
}

- (void)registerOrLogin {
   // NSLog(@"in showing the register login options");
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Tutorial_iPhone" bundle:nil];
    
    TutorialOptionViewController *tutorialViewController = (TutorialOptionViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"TutorialOptionViewController"];
    
    
    self.window.rootViewController = tutorialViewController;
    [self.window makeKeyAndVisible];
    
}

- (void)displayTutorial {
    
   // NSLog(@"in showing the tutorial");
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Tutorial_iPhone" bundle:nil];
    
    TutorialViewController *tutorialViewController = (TutorialViewController*)[mainStoryboard
                                                                               instantiateViewControllerWithIdentifier: @"TutorialViewController"];
    
   // NSLog(@"shpwing iiiiiit");
    
    self.window.rootViewController = tutorialViewController;
    [self.window makeKeyAndVisible];
    
}

- (BOOL)connectedToInternet
{
    NSURL *url=[NSURL URLWithString:@"http://www.google.com"];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"HEAD"];
    NSHTTPURLResponse *response;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: NULL];
    
    return ([response statusCode]==200)?YES:NO;
}

- (NSString*)login:(NSString*)username password:(NSString*)password {
    
    isLogin = true;
    
    NSString* responseMessage = @"";
    
    NSMutableDictionary *json= [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *deviceDetails= [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *userDetails= [[NSMutableDictionary alloc] init];
    
    UIDevice *device = [UIDevice currentDevice];
    
    NSString *deviceOSId = [[device identifierForVendor]UUIDString];
    
    NSString *device_model = [device model];
    
   // NSLog(@"i am now loging in");
    
    // NSString *deviceOSId = @"2709";
    
    //NSString *device_model = @"Simulator";
    
    
    [deviceDetails setObject:deviceOSId forKey:@"deviceOSId"];
    [deviceDetails setObject:@"Apple" forKey:@"device_make"];
    [deviceDetails setObject:device_model forKey:@"device_model"];
    [deviceDetails setObject:@"iOS" forKey:@"platform"];
    [json setObject:deviceDetails forKey:@"device"];
    
    [userDetails setObject:username forKey:@"username"];
    [userDetails setObject:password forKey:@"password"];
    [json setObject:userDetails forKey:@"user"];
    
    userName = username;
    pass = password;
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    //NSLog(@"%@", jsonString);
    
    //perform post
    
    //http://86.132.218.95:2709
    //http://jamescross91.no-ip.biz:2709
    
    NSURL *url = [NSURL URLWithString:@"http://toread.gocolibri.com:2709/api/login"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLResponse *response;
    NSError *err;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    int responseCode = [(NSHTTPURLResponse*)response statusCode];
    NSLog(@"responseCode %i", responseCode);
    
    if (responseCode != 0) {
        responseMessage = [self parseResponse:responseData];
    } else {
        responseMessage = @"Server Down";
    }
    
    if (![responseMessage isEqualToString:@"Invalid username or password"] || ![responseMessage isEqualToString:@"(null)"] || ![responseMessage isEqualToString:@"Server Down"]) {
       // NSLog(@"i can authenticate now");
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasAuthenticated"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return responseMessage;
    
}

- (NSString*)registerUser:(NSString*)username password:(NSString*)password firstName:(NSString*)firstName
                 lastName:(NSString*)lastName emailAddress:(NSString*)emailAddress ageRange:(NSString*)ageRange
                      sex:(NSString*)sex occupation:(NSString*)occupation {
    
    NSString* responseMessage;
    
    NSMutableDictionary *json= [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *deviceDetails= [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *userDetails= [[NSMutableDictionary alloc] init];
    
    UIDevice *device = [UIDevice currentDevice];
    
    NSString *deviceOSId = [[device identifierForVendor]UUIDString];
    
    NSString *device_model = [device model];
    
   // NSLog(@"authenticating first time");
    
    //NSString *deviceOSId = @"2709";
    
    //NSString *device_model = @"Simulator";
    
    
    [deviceDetails setObject:deviceOSId forKey:@"deviceOSId"];
    [deviceDetails setObject:@"Apple" forKey:@"device_make"];
    [deviceDetails setObject:device_model forKey:@"device_model"];
    [deviceDetails setObject:@"iOS" forKey:@"platform"];
    [json setObject:deviceDetails forKey:@"device"];
    
    [userDetails setObject:username forKey:@"username"];
    [userDetails setObject:password forKey:@"password"];
    [userDetails setObject:firstName forKey:@"first_name"];
    [userDetails setObject:lastName forKey:@"last_name"];
    [userDetails setObject:emailAddress forKey:@"email_address"];
    [userDetails setObject:ageRange forKey:@"age_range"];
    [userDetails setObject:sex forKey:@"sex"];
    [userDetails setObject:occupation forKey:@"occupation"];
    [json setObject:userDetails forKey:@"user"];
    
    userName = username;
    pass = password;
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
   // NSLog(@"%@", jsonString);
    
    //perform post
    
    //http://86.132.218.95:2709
    //http://jamescross91.no-ip.biz:2709
    
    NSURL *url = [NSURL URLWithString:@"http://toread.gocolibri.com:2709/api/register/user"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLResponse *response;
    NSError *err;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
   // NSLog(@"%@", jsonString);
    
    if (responseData != nil && responseData != NULL) {
        
        NSLog(@"in here");
        
        @try{
            responseMessage = [self parseResponse:responseData];
        }
        @catch (NSException * e) {
            NSLog(@"say the server is downnnnnn");
        }
    } else {
        NSLog(@"say the server is down");
    }
    
  
    
    if (![responseMessage isEqualToString:@"Username already exists"] || ![responseMessage isEqualToString:@"(null)"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasAuthenticated"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return responseMessage;
    
}

- (NSString*)performSingleAuthentication {
    NSMutableDictionary *json= [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *authDetails= [[NSMutableDictionary alloc] init];
    
   // NSLog(@"performing authentication");
    
    [authDetails setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_name"] forKey:@"username"];
    [authDetails setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"auth_token"] forKey:@"token"];
    [authDetails setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceID"] forKey:@"device_id"];
    [json setObject:authDetails forKey:@"auth_data"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return jsonString;
    
}

- (NSString*)performSyncRequest {
    NSMutableDictionary *json= [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *authDetails= [[NSMutableDictionary alloc] init];
    
    [authDetails setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_name"] forKey:@"username"];
    [authDetails setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"auth_token"] forKey:@"token"];
    [authDetails setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceID"] forKey:@"device_id"];
    [json setObject:authDetails forKey:@"auth_data"];
    
    NSMutableArray *bookIDarray = [[NSMutableArray alloc] init];
    
    [self getAllDatabaseTableNames];
    
    for (NSString *collectionName in self.tableNames) {
        NSMutableArray *ISBNs = [[NSMutableArray alloc] init];
        
        
        
        if (![collectionName isEqualToString:@"suggestedBooks"]) {
            ISBNs = [self getAllISBNsFromTable:collectionName];
            
            if (ISBNs.count != 0) {
                
                for (NSString *bookISBN in ISBNs) {
                    
                    NSMutableDictionary *bookIDs = [[NSMutableDictionary alloc] init];
                    [bookIDs setValue:bookISBN forKey:@"ISBN"];
                    [bookIDs setValue:collectionName forKey:@"collection"];
                    
                    [bookIDarray addObject:bookIDs];
                }
            }
        }
    }
    
    
    //add all the dictionaries to the array;
    [json setObject:bookIDarray forKey:@"book_ids"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@", jsonString);
    
    return jsonString;
}

- (NSMutableArray*) getAllISBNsFromTable:(NSString*)tableName {
    
    
    NSMutableArray *ISBNs = [[NSMutableArray alloc] init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"books.sqlite"];
    
   // NSLog(@"path %@", path);
    
    //Open the db. The db was prepared outside the application
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        //Get the primary key for all the books
        
        const char *sql = [[NSString stringWithFormat:@"SELECT ID FROM %@", tableName] UTF8String];
       // NSLog(@"%s",sql);
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
            // We step through the results once for each row.
           // NSLog(@"in sql results app delegate");
          //  NSLog(@"sqlite row : %d", SQLITE_ROW);
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
               // NSLog(@"in SQL");
                
                int ID = sqlite3_column_int(statement, 0);
                
               // NSLog(@"ID is %i", ID);
                
                sqlite3_stmt *statementC;
                
                const char *sqlC = [[NSString stringWithFormat:@"SELECT COUNT(*) from %@", tableName] UTF8String];
                
                int nb = 0;
                
                if (sqlite3_prepare_v2(database, sqlC, -1, &statementC, NULL) == SQLITE_OK) {
                    while (sqlite3_step(statementC) == SQLITE_ROW) {
                        nb = sqlite3_column_int(statementC, 0);
                    }
                }
                
              //  NSLog(@"%s, %i", sqlC, nb);
                
                sqlite3_finalize(statementC);
                
                const char *sql2 = [[NSString stringWithFormat:@"SELECT ISBN FROM %@ WHERE ID = %i", tableName, ID] UTF8String];
                
              //  NSLog(@"%s", sql2);
                
                sqlite3_stmt *statement2;
                if (sqlite3_prepare_v2(database, sql2, -1, &statement2, NULL) == SQLITE_OK && nb!=0) {
                    while (sqlite3_step(statement2) == SQLITE_ROW) {
                    //    NSLog(@"in ISBN");
                        
                        NSString *ISBN = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement2, 0)];
                        
                    //    NSLog(@"ISBN is %@", ISBN);
                        
                        [ISBNs addObject:ISBN];
                    }
                }
                
                sqlite3_finalize(statement2);
                
            }
        }
        //NSLog(@"Number of ISBNs from the DB: %lu", (unsigned long)ISBNs.count);
        // finalize the statement
        sqlite3_finalize(statement);
        sqlite3_close(database);
    } else {
        //even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open DB with message '%s' .", sqlite3_errmsg(database));
    }
    
    return ISBNs;
}

- (void) syncWithTheServer:(NSString*)jsonString {
    
    //perform post
    NSURL *url = [NSURL URLWithString:@"http://toread.gocolibri.com:2709/api/sync/clientlist"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLResponse *response;
    NSError *err;
    NSData *jsonResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    NSError *error;
    
    
    NSLog(@"syncing response: %@", response);
   // NSLog(@"%@", [[NSString alloc] initWithData:jsonResponseData encoding:NSUTF8StringEncoding]);
    
    NSDictionary* jsonResponseDict = [NSJSONSerialization
                                      JSONObjectWithData:jsonResponseData
                                      options:0
                                      error:&error];
   
   NSLog(@"syncing details %@", jsonResponseDict);
}

- (void)createDatabaseEntries:(NSData*)jsonResponseData {
    
    self.retrieveBooks = [[RetrieveBooks alloc] init];
    
    NSError *error;
    
   // NSLog(@"%@", [[NSString alloc] initWithData:jsonResponseData encoding:NSUTF8StringEncoding]);
    
    NSDictionary* jsonResponseDict = [NSJSONSerialization
                                      JSONObjectWithData:jsonResponseData
                                      options:0
                                      error:&error];
    
   // NSLog(@"response dict %@", jsonResponseDict);
    
    NSArray* loginTables = [jsonResponseDict objectForKey:@"collections"];
    
    for (int i=0; i < [loginTables count]; i++) {
        
        NSString* collectionName = [loginTables[i] objectForKey:@"collection_name"];
        
     //   NSLog(@"collectionNAME: %@", collectionName);
        
        [self createNewCustomListInTheDatabase:[collectionName stringByReplacingOccurrencesOfString:@"Books" withString:@""]];
        
        NSMutableArray* collectionBooks = [loginTables[i] objectForKey:@"books"];
        
        for (NSString* ISBN in collectionBooks) {
            NSData* dataFromURL = [self.retrieveBooks getDataFromURLAsData:
                                   [NSString stringWithFormat:@"https://www.googleapis.com/books/v1/volumes?q=isbn:%@", ISBN]];
            
            NSArray* result = [self.retrieveBooks parseJson:[self.retrieveBooks getJsonFromData:dataFromURL]];
            
            NSString* coverLink = [[[[result objectAtIndex:0] objectForKey:@"volumeInfo"] objectForKey:@"imageLinks"] objectForKey:@"thumbnail"];
            
            NSString* title = [[[result objectAtIndex:0] objectForKey:@"volumeInfo"] objectForKey:@"title"];
            NSString* bookAuthors = @"";
            
            if ([[[result objectAtIndex:0] objectForKey:@"volumeInfo"] objectForKey:@"authors"] != nil) {
                NSLog(@"not nil");
                NSArray *authors = [[[result objectAtIndex:0] objectForKey:@"volumeInfo"] objectForKey:@"authors"];
                
             //   NSLog(@" authors %@", authors);
                
                for (NSString* author in authors) {
                    bookAuthors = [bookAuthors stringByAppendingString:[NSString stringWithFormat:@"%@; ",author]];
                }
                
                bookAuthors = [bookAuthors substringToIndex:[bookAuthors length] - 2]; //to remove the last ;
            } else {
                bookAuthors = @"";
            }
            
            
            NSString* editor = [[[result objectAtIndex:0] objectForKey:@"volumeInfo"] objectForKey:@"publisher"];
            
            
            NSDecimalNumber *ratings;
            double rating;
            
            if ([[[result objectAtIndex:0] objectForKey:@"volumeInfo"] objectForKey:@"averageRating"] != nil) {
                ratings = [[[result objectAtIndex:0] objectForKey:@"volumeInfo"] objectForKey:@"averageRating"];
                rating = [ratings doubleValue];
            } else {
                rating = 0.0;
            }
            
            
            NSString* desc = [[[result objectAtIndex:0] objectForKey:@"volumeInfo"] objectForKey:@"description"];
            
            [self addBookToTheDatabaseBookList:[collectionName stringByReplacingOccurrencesOfString:@"Books" withString:@""] bookTitle:title bookAuthors:bookAuthors publisher:editor coverLink:coverLink rating:rating isbn:ISBN desc:desc];
            
        }
    }
    
    
    
    
    
    
}

- (NSString*) parseResponse:(NSData*)jsonResponseData {
    
    NSError *error;
    
   // NSLog(@"%@", [[NSString alloc] initWithData:jsonResponseData encoding:NSUTF8StringEncoding]);
    
    NSDictionary* jsonResponseDict = [NSJSONSerialization
                                      JSONObjectWithData:jsonResponseData
                                      options:0
                                      error:&error];
    
   // NSLog(@"response dict %@", jsonResponseDict);
    
    NSString* responseMessage;
    
    responseMessage = [jsonResponseDict objectForKey:@"message"];
    
    // NSString *userName = [jsonResponseDict objectForKey:@"user_name"];
    if (!isLogin && ![responseMessage isEqualToString:@"Username already exists"] ) {
        NSString *authToken = [[jsonResponseDict objectForKey:@"device"] objectForKey:@"auth_token"];
        NSString *deviceID = [[jsonResponseDict objectForKey:@"device"] objectForKey:@"tr_device_id"];
        
        [[NSUserDefaults standardUserDefaults] setObject:userName forKey:@"user_name"];
        [[NSUserDefaults standardUserDefaults] setObject:pass forKey:@"password"];
        [[NSUserDefaults standardUserDefaults] setObject:authToken forKey:@"auth_token"];
        [[NSUserDefaults standardUserDefaults] setObject:deviceID forKey:@"deviceID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
    //check here the message
    if (isLogin && ![responseMessage isEqualToString:@"Invalid username or password"]) {
        NSString *authToken = [jsonResponseDict objectForKey:@"auth_token"];
        NSString *deviceID = [jsonResponseDict objectForKey:@"tr_device_id"];
        [[NSUserDefaults standardUserDefaults] setObject:userName forKey:@"user_name"];
        [[NSUserDefaults standardUserDefaults] setObject:pass forKey:@"password"];
        [[NSUserDefaults standardUserDefaults] setObject:authToken forKey:@"auth_token"];
        [[NSUserDefaults standardUserDefaults] setObject:deviceID forKey:@"deviceID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    //NSLog(@"USER %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"user_name"]);
    
    return responseMessage;
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

- (void)requestSuggestedBooksAndAddThemToTheDatabase:(NSString*)jsonString {
    
  //  NSLog(@"requesting books from the server");
    
    //perform post
    NSURL *url = [NSURL URLWithString:@"http://toread.gocolibri.com:2709/api/suggest/bestsell"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLResponse *response;
    NSError *err;
    NSData *jsonResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    
    [self deleteTableFromDatabase:@"suggested"];
    
    [self createNewCustomListInTheDatabase:@"suggested"];
    
    NSError *error;
    
   // NSLog(@"%@", [[NSString alloc] initWithData:jsonResponseData encoding:NSUTF8StringEncoding]);
    
    NSDictionary* jsonResponseDict = [NSJSONSerialization
                                      JSONObjectWithData:jsonResponseData
                                      options:0
                                      error:&error];
    
   // NSLog(@"dict %@", jsonResponseDict);
    
    NSArray *items = [jsonResponseDict objectForKey:@"best_sellers"];
    
    for (int i=0; i < [items count]; i++) {
        NSString *title = @"";
        
        title = [items[i] objectForKey:@"title"];
        
        NSString* authors = @"";
        
        NSArray *authorsArray = [items[i] objectForKey:@"authors"];
        
      //  NSLog(@" authors %@", authorsArray);
        
        for (NSDictionary* author in authorsArray) {
            
            authors = [authors stringByAppendingString:[NSString stringWithFormat:@"%@; ",[author objectForKey:@"Name"]]];
        }
        
        authors = [authors substringToIndex:[authors length] - 2];
        
        NSString *coverLink = @"";
        
        coverLink = [items[i] objectForKey:@"cover_url"];
        
        NSString *isbn = @"";
        
        isbn = [items[i] objectForKey:@"ISBN"];
        
        double rating = 0.0;
        NSString* publisher = @"";
        NSString* desc = @"";
        
        if(coverLink != NULL && ![coverLink  isEqualToString:@""]) {
          //  NSLog (@"cover not null %@", coverLink);
            [self addBookToTheDatabaseBookList:@"suggested" bookTitle:title bookAuthors:authors publisher:publisher coverLink:coverLink rating:rating isbn:isbn desc:desc];
            NSLog(@"ADDED");
        }
        
    }
        
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastUpdated"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"DATE: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"lastUpdated"]);

}

-(int)howManyDaysHavePast:(NSDate*)lastDate today:(NSDate*)today {
    NSDate *startDate = lastDate;
    NSDate *endDate = today;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSDayCalendarUnit fromDate:startDate toDate:endDate options:0];
    int days = [components day];
    NSLog(@"days passed: %i", days);
    
    return days;
}



//open the db connection and retrieve minimal information for all objects
- (void)initializeSuggestedBooksDatabase {
    self.suggestedBooks = nil;
    
    NSMutableArray *suggestedBooksArray = [[NSMutableArray alloc] init];
    self.suggestedBooks = suggestedBooksArray;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"books.sqlite"];
    
   // NSLog(@"path %@", path);
    //Open the db. The db was prepared outside the application
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        //Get the primary key for all the books
        
        NSString *tableName = @"suggestedBooks";
        
        const char *sql = [[NSString stringWithFormat:@"SELECT ID FROM %@", tableName] UTF8String];
      //  NSLog(@"%s",sql);
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
            // We step through the results once for each row.
         //   NSLog(@"in sql results app delegate");
        //    NSLog(@"sqlite row : %d", SQLITE_ROW);
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
           //     NSLog(@"in SQL");
                int ID = sqlite3_column_int(statement, 0);
           //     NSLog(@"ID is %i", ID);
                BooksDatabase *bDB = [[BooksDatabase alloc]initWithPrimaryKey:ID database:database table:tableName];
                [suggestedBooks addObject:bDB];
                
                //remove old images if needed
                if([self howManyDaysHavePast:[[NSUserDefaults standardUserDefaults] valueForKey:@"lastUpdated"] today:[NSDate date]]>=7)
                {
                    NSLog(@"I can remove the images and download new ones");
                    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                
                    NSString *imageN = [NSString stringWithFormat:@"suggestedBooks%ld.png",(long)bDB.ID];
                
                    NSLog(@"imageNAme %@", imageN);
                
                    NSString* pngFilePath = [NSString stringWithFormat:@"%@/%@",docDir, imageN];
                    [self removeImage:pngFilePath];
                }
            }
        }
      //  NSLog(@"Number of SUGGESTED from the DB: %lu", (unsigned long)suggestedBooks.count);
        // finalize the statement
        sqlite3_finalize(statement);
        sqlite3_close(database);
    } else {
        //even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open DB with message '%s' .", sqlite3_errmsg(database));
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

- (void)createNewCustomListInTheDatabase:(NSString *)name {
    
    NSString* tableName = [name lowercaseString];
    
    tableName = [tableName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"books.sqlite"];
    
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        //Get the primary key for all the books
        
        const char *sql = [[NSString stringWithFormat:@"create table if not exists %@Books (ID INTEGER PRIMARY KEY, TITLE VARCHAR(300), AUTHORS VARCHAR(300), EDITOR VARCHAR(300), COVERLINK VARCHAR(300), DUEDATE VARCHAR(50), RATING REAL DEFAULT 0, ISBN VARCHAR(30) UNIQUE, DESC VARCHAR(4096))", tableName] UTF8String];
        //NSLog(@"%s",sql);
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
            // We step through the results once for each row.
          //  NSLog(@"in sql results app delegate");
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
             //   NSLog(@"in SQL");
               // int ID = sqlite3_column_int(statement, 0);
               // NSLog(@"ID is %i", ID);
                
               // NSLog(@"DONE");
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
       // NSLog(@"%s",sql);
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
            // We step through the results once for each row.
           // NSLog(@"in sql results app delegate");
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
               // NSLog(@"in SQL");
                //int ID = sqlite3_column_int(statement, 0);
               // NSLog(@"ID is %i", ID);
                
                [tableNames addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)]];
                
             //   NSLog(@"DONE");
            }
        }
      //  NSLog(@"Number of TABLES from the DB: %lu", (unsigned long)tableNames.count);
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
       // NSLog(@"%s",sql);
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
            // We step through the results once for each row.
          //  NSLog(@"in sql results app delegate");
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
              //  NSLog(@"in SQL");
                int ID = sqlite3_column_int(statement, 0);
              //  NSLog(@"ID is %i", ID);
                BooksDatabase *bDB = [[BooksDatabase alloc]initWithPrimaryKey:ID database:database table:tableName];
                [customListBooks addObject:bDB];
            }
        }
       // NSLog(@"Number of items from the DB: %lu", (unsigned long)customListBooks.count);
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
       // NSLog(@"%s",sql);
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
            // We step through the results once for each row.
          //  NSLog(@"in sql results app delegate");
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
              //  NSLog(@"in SQL");
                int ID = sqlite3_column_int(statement, 0);
              //  NSLog(@"ID is %i", ID);
                BooksDatabase *bDB = [[BooksDatabase alloc]initWithPrimaryKeyAllDetails:ID database:database table:tableName];
                [customListBooks addObject:bDB];
            }
        }
       // NSLog(@"Number of items from the DB: %lu", (unsigned long)customListBooks.count);
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
       // NSLog(@"%s",sql);
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
            // We step through the results once for each row.
          //  NSLog(@"in sql results app delegate");
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
              //  NSLog(@"in SQL");
                int ID = sqlite3_column_int(statement, 0);
              //  NSLog(@"ID is %i", ID);
                BooksDatabase *bDB = [[BooksDatabase alloc]initWithPrimaryKey:ID database:database table:@"favouriteBooks"];
                [favouriteBooks addObject:bDB];
            }
        }
      //  NSLog(@"Number of items from the DB: %lu", (unsigned long)favouriteBooks.count);
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
      //  NSLog(@"%s",sql);
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
            // We step through the results once for each row.
          //  NSLog(@"in sql results app delegate");
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
             //   NSLog(@"in SQL");
                int ID = sqlite3_column_int(statement, 0);
             //   NSLog(@"ID is %i", ID);
                BooksDatabase *bDB = [[BooksDatabase alloc]initWithPrimaryKeyAllDetails:ID database:database table:@"favouriteBooks"];
                [favouriteBooks addObject:bDB];
            }
        }
      //  NSLog(@"Number of items from the DB: %lu", (unsigned long)favouriteBooks.count);
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
    
   // NSLog(@"path %@", path);
    //Open the db. The db was prepared outside the application
    
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        const char *sql = [[NSString stringWithFormat:@"INSERT INTO readBooks(TITLE, AUTHORS, EDITOR, COVERLINK, DUEDATE, RATING, ISBN, DESC) SELECT TITLE, AUTHORS, EDITOR, COVERLINK, DUEDATE, RATING, ISBN, DESC FROM %@ WHERE ID = %lu ", tableName, (unsigned long)ID] UTF8String];
      //  NSLog(@"%s",sql);
        
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
    
   // NSLog(@"path %@", path);
    //Open the db. The db was prepared outside the application
    
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        const char *sql = [[NSString stringWithFormat:@"DELETE FROM %@ WHERE ID = %lu", tableName, (unsigned long)ID] UTF8String];
      //  NSLog(@"%s",sql);
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
    
   // NSLog(@"path %@", path);
    //Open the db. The db was prepared outside the application
    
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        const char *sql = [[NSString stringWithFormat:@"DELETE FROM %@ WHERE ID = %lu", tableName, (unsigned long)ID] UTF8String];
      //  NSLog(@"%s",sql);
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

- (void)deleteTableFromDatabase:(NSString *)tableName {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"books.sqlite"];
    
   // NSLog(@"path %@", path);
    //Open the db. The db was prepared outside the application
    
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        const char *sql = [[NSString stringWithFormat:@"DROP TABLE %@Books", tableName] UTF8String];
      //  NSLog(@"%s",sql);
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
            if (sqlite3_step(statement) != SQLITE_DONE)
                return;
            [tableNames removeObject:tableName];
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
    
    tableName = [tableName stringByReplacingOccurrencesOfString:@" " withString:@"_"];

   // NSLog(@"path %@", path);
    //Open the db. The db was prepared outside the application
    
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        const char *sql = [[NSString stringWithFormat:@"INSERT INTO %@Books (TITLE,AUTHORS,EDITOR,COVERLINK,DUEDATE,RATING,ISBN,DESC) VALUES(?,?,?,?,?,?, ?, ?)", tableName] UTF8String];
       // NSLog(@"%s",sql);
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
            
            sqlite3_bind_text(statement, 1, [bookTitle UTF8String], -1, SQLITE_TRANSIENT);
            NSLog(@"1");
            sqlite3_bind_text(statement, 2, [bookAuthors UTF8String], -1, SQLITE_TRANSIENT);
            NSLog(@"2");
            sqlite3_bind_text(statement, 3, [publisher UTF8String], -1, SQLITE_TRANSIENT);
            NSLog(@"3");
            sqlite3_bind_text(statement, 4, [coverLink UTF8String], -1, SQLITE_TRANSIENT);
            NSLog(@"4");
            sqlite3_bind_text(statement, 5, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            NSLog(@"5");
            sqlite3_bind_double(statement, 6, rating);
            NSLog(@"6");
            sqlite3_bind_text(statement, 7, [isbn UTF8String], -1, SQLITE_TRANSIENT);
            NSLog(@"7");
            sqlite3_bind_text(statement, 8, [desc UTF8String], -1, SQLITE_TRANSIENT);
            NSLog(@"8");
            
            if (sqlite3_step(statement) != SQLITE_DONE) {
                return;
            }
            
        }
        
      //  NSLog(@"finalizes statement");
        // finalize the statement
        sqlite3_finalize(statement);
        sqlite3_close(database);
    } else {
        //even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open DB with message '%s' .", sqlite3_errmsg(database));
    }
    
    
}

- (int)getNumberOfFavouriteBooksFromDB {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"books.sqlite"];
    
    int favouriteNb = 0;
    
   // NSLog(@"path %@", path);
    //Open the db. The db was prepared outside the application
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        const char *sql = [[NSString stringWithFormat:@"SELECT COUNT(*) from favouriteBooks"] UTF8String];
      //  NSLog(@"%s",sql);
        sqlite3_stmt *statement;
        
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
            
            if (sqlite3_step(statement) == SQLITE_ERROR) {
                NSAssert1(0,@"Error when counting rows  %s",sqlite3_errmsg(database));
            } else {
                favouriteNb = sqlite3_column_int(statement, 0);
               // NSLog(@"SQLite Rows: %i", favouriteNb);
            }
            sqlite3_finalize(statement);
        }
        
        sqlite3_close(database);
        
    }     else {
        //even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open DB with message '%s' .", sqlite3_errmsg(database));
    }
    
    return favouriteNb;
    
}

- (int)getNumberOfBooksFromDB:(NSString*)tableName {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"books.sqlite"];
    
    int nb = 0;
    
   // NSLog(@"path %@", path);
    //Open the db. The db was prepared outside the application
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        const char *sql = [[NSString stringWithFormat:@"SELECT ID FROM %@Books", tableName] UTF8String];
      //  NSLog(@"%s",sql);
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
            // We step through the results once for each row.
          //  NSLog(@"in sql results app delegate");
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
              //  NSLog(@"in SQL");
                nb = sqlite3_column_int(statement, 0);
             //   NSLog(@"ID is %i", nb);
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
        
    }     else {
        //even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open DB with message '%s' .", sqlite3_errmsg(database));
    }
    
    return nb;
}

- (int)getNumberOfReadBooksFromDB {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"books.sqlite"];
    
    int readBooksNB = 0;
    
   // NSLog(@"path %@", path);
    //Open the db. The db was prepared outside the application
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        const char *sql = [[NSString stringWithFormat:@"SELECT COUNT(*) from readBooks"] UTF8String];
      //  NSLog(@"%s",sql);
        sqlite3_stmt *statement;
        
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
            
            if (sqlite3_step(statement) == SQLITE_ERROR) {
                NSAssert1(0,@"Error when counting rows  %s",sqlite3_errmsg(database));
            } else {
                readBooksNB = sqlite3_column_int(statement, 0);
              //  NSLog(@"SQLite Rows: %i", readBooksNB);
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
    NSLog(@"syncing with the server");
    [self authenticateAndSyncRegularly];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    if (([[NSUserDefaults standardUserDefaults] objectForKey:@"auth_token"] == NULL || [[[NSUserDefaults standardUserDefaults] objectForKey:@"auth_token"] isEqualToString:@"(null)"]) && [[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenTutorial"]) {
            [self registerOrLogin];
    }  else if (([[NSUserDefaults standardUserDefaults] objectForKey:@"auth_token"] == NULL || [[[NSUserDefaults standardUserDefaults] objectForKey:@"auth_token"] isEqualToString:@"(null)"]) && ![[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenTutorial"]) {
            [self displayTutorial];
    } /*else if ([self connectedToInternet] && [[NSUserDefaults standardUserDefaults] boolForKey:@"hasAuthenticated"]) {
        
            NSLog(@"syncing with the server");
            [self authenticateAndSyncRegularly];
     }*/
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    //NSLog(@"syncing with the server");
    //[self authenticateAndSyncRegularly];
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"To read!" message:notification.alertBody delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    
    [alert show];
}

@end
