//
//  BooksDatabase.m
//  readiOS
//
//  Created by Ingrid Funie on 24/04/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import "BooksDatabase.h"

static sqlite3_stmt *init_statement = nil;

@implementation BooksDatabase
@synthesize ID,title,authors,editor,coverLink,dueDate;

- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db table:(NSString *)tableName{
    
    init_statement = nil;
    
    if (self = [super init]) {
        ID = pk;
        database = db;
        if (init_statement == nil) {
            //i need to get the id as well and then when i get all the details
            
            const char *sql = [[NSString stringWithFormat:@"SELECT COVERLINK FROM %@ WHERE ID = ?", tableName] UTF8String];
            
            if (sqlite3_prepare_v2(database, sql, -1, &init_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"ERROR: failed to prepare statement with message '%s' .", sqlite3_errmsg(database));
            }
        }
        // For this query, we bind the primary key to the first (and only) placeholder in the statement
        sqlite3_bind_int(init_statement, 1, (int)ID);
        if (sqlite3_step(init_statement) == SQLITE_ROW) {
            self.coverLink = [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 0)];
            //self.ID = sqlite3_column_int(init_statement,0);
            NSLog(@"DONE %@", self.coverLink);
                 } else {
            self.coverLink = @"";
        }
        // reset the statement for future reuse
        sqlite3_reset(init_statement);
    }
    
    return self;
}

- (id)initWithPrimaryKeyAllDetails:(NSInteger)pk database:(sqlite3 *)db table:(NSString *)tableName {
    
    init_statement = nil;
    
    if (self = [super init]) {
        ID = pk;
        database = db;
        if (init_statement == nil) {
            const char *sql = [[NSString stringWithFormat:@"SELECT TITLE, AUTHORS, EDITOR, COVERLINK, DUEDATE FROM %@ WHERE ID = %li", tableName, (long)ID] UTF8String];
            NSLog(@"%s", sql);
            
            if (sqlite3_prepare_v2(database, sql, -1, &init_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"ERROR: failed to prepare statement with message '%s' .", sqlite3_errmsg(database));
            }
        }
        if (sqlite3_step(init_statement) == SQLITE_ROW) {
            
            NSLog(@"entering to save the details data");
            
            self.title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 0)];
            NSLog(@"done %@", self.title);
             self.authors = [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 1)];
             NSLog(@"done");
             self.editor = [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 2)];
             NSLog(@"done");
            self.coverLink = [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 3)];
            NSLog(@"DONE %@", self.coverLink);
            self.dueDate = @""; //need to check this
            
        } else {
            self.title = @"Nothing";
            self.authors = @"Nothing";
            self.editor = @"Nothing";
            self.coverLink = @"Nothing";
            self.dueDate = @"";
        }
        // reset the statement for future reuse
        sqlite3_reset(init_statement);
    }
    
    return self;

}


@end
