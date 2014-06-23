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

@interface SearchResultsController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate,  MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
}

@property(strong, nonatomic) NSArray* tableData;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (retain) RetrieveBooks *retrieveBooks;

-(void)setTableDataArray:(NSArray *)table;
- (IBAction)dismissView:(id)sender;

@end
