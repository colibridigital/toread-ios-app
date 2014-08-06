//
//  ReadingListManager.h
//  readiOS
//
//  Created by Ingrid Funie on 23/07/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ReadingListManager : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (retain) AppDelegate *appDelegate;

- (IBAction)dismissView:(id)sender;

@property (strong, nonatomic) NSMutableArray *tableNames;

@end
