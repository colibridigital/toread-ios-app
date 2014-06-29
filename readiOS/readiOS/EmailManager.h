//
//  EmailManager.h
//  readiOS
//
//  Created by Ingrid Funie on 27/06/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "BooksDatabase.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface EmailManager : UIViewController<MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) AppDelegate *appDelegate;
@property (nonatomic) BooksDatabase *bDB;
@property (strong, nonatomic) NSMutableArray *listResult;
@property (nonatomic) NSString *listName;
@property (nonatomic) NSString *filePath;

-(void)saveDetailsFromDatabaseList:(NSString*)list;
- (MFMailComposeViewController*)displayComposerSheet;
@end
