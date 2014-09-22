//
//  SearchResultsController.h
//  readiOS
//
//  Created by Ingrid Funie on 20/05/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RetrieveBooks.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"

@interface SearchResultsController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate,  MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
}

@property(strong, nonatomic) NSArray* tableData;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (retain) RetrieveBooks *retrieveBooks;
@property (weak, nonatomic) AppDelegate *appDelegate;

-(void)setTableDataArray:(NSArray *)table;
- (IBAction)dismissView:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *returnButton;
@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (nonatomic) BOOL isShown;

@end
