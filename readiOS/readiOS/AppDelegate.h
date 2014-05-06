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
    NSMutableArray *readBooks;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) NSMutableArray *suggestedBooks;
@property (nonatomic, retain) NSMutableArray *favouriteBooks;
@property (nonatomic, retain) NSMutableArray *customListBooks;

- (void)moveBooksToReadInTheDatabase:(NSString *)tableName ID:(NSInteger)ID indexPath:(NSInteger)indexPath;

- (void)deleteBooksToReadFromOriginalTable:(NSString *)tableName ID:(NSInteger)ID;
- (void)setupMenu:(UIViewController *)mainViewController;
@end
