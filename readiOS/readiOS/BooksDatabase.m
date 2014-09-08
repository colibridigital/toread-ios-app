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
@synthesize ID,title,authors,editor,coverLink,dueDate, rating, isbn, desc;

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
            @try {
            self.coverLink = [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 0)];
            }
            @catch (NSException* e) {
                NSLog(@"exception %@", e);
            }
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
            const char *sql = [[NSString stringWithFormat:@"SELECT TITLE, AUTHORS, EDITOR, COVERLINK, DUEDATE, RATING, ISBN, DESC FROM %@ WHERE ID = %li", tableName, (long)ID] UTF8String];
            NSLog(@"%s", sql);
            
            if (sqlite3_prepare_v2(database, sql, -1, &init_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"ERROR: failed to prepare statement with message '%s' .", sqlite3_errmsg(database));
            }
        }
        if (sqlite3_step(init_statement) == SQLITE_ROW) {
            
            NSLog(@"entering to save the details data");
            
            @try {
                self.title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 0)];
                NSLog(@"done %@", self.title);
            }
            @catch (NSException *e) {
                NSLog(@"exception thrown %@", e);
            }
            
            @try{
                self.authors = [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 1)];
                NSLog(@"done %@", self.authors);
            }
            @catch (NSException *e) {
                NSLog(@"exception thrown %@", e);
            }
            
            @try{
                self.editor = [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 2)];
                NSLog(@"done %@", self.editor);
            }
            @catch (NSException *e) {
                NSLog(@"exception thrown %@", e);
            }
            
            @try{
                self.coverLink = [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 3)];
                NSLog(@"DONE %@", self.coverLink);
                
            }
            @catch (NSException *e) {
                NSLog(@"exception thrown %@", e);
            }
            
            @try {
                self.dueDate = [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 4)];
            }
            
            @catch (NSException *e) {
                NSLog(@"exception thrown %@", e);
            }
            
            @try{
                
                self.rating = sqlite3_column_double(init_statement, 5);
            }
            
            @catch (NSException *e) {
                NSLog(@"exception thrown %@", e);
            }
            
            
            @try{
                self.isbn = [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 6)];
                NSLog(@"done %@", self.isbn);
            }
            
            
            @catch (NSException *e) {
                NSLog(@"exception thrown %@", e);
            }
            
            @try {
                self.desc = [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 7)];
                NSLog(@"done %@", self.desc);
            }
            
            @catch (NSException *e) {
                NSLog(@"exception thrown %@", e);
            }
            
            
            
        } else {
            
            self.authors = @"";
            self.editor = @"";
            self.coverLink = @"";
            self.dueDate = @"";
            self.rating = 0.0;
            self.isbn = @"";
            self.desc = @"";
        }
        // reset the statement for future reuse
        sqlite3_reset(init_statement);
    }
    
    return self;
    
}


@end
