//
//  BooksDatabase.h
//  readiOS
//
//  Created by Ingrid Funie on 24/04/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import <UIKit/UIKit.h>

@interface BooksDatabase : NSObject {
    sqlite3 *database;
    NSInteger ID;
    NSString *title;
    NSString *authors;
    NSString *editor;
    NSString *coverLink;
    NSString *dueDate;
    double rating;
}

@property (assign, nonatomic, readonly) NSInteger ID;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *authors;
@property (nonatomic, retain) NSString *editor;
@property (nonatomic, retain) NSString *coverLink;
@property (nonatomic, retain) NSString *dueDate;
@property (nonatomic) double rating;

- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db table:(NSString *)tableName;

- (id)initWithPrimaryKeyAllDetails:(NSInteger)pk database:(sqlite3 *)db table:(NSString *)tableName;


@end
