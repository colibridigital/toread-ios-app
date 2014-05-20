//
//  SearchResultsController.h
//  readiOS
//
//  Created by Ingrid Funie on 20/05/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultsController : UIViewController<UITableViewDataSource, UITableViewDelegate> {

}

@property(strong, nonatomic) NSArray* tableData;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

-(void)setTableDataArray:(NSArray *)table;
- (IBAction)dismissView:(id)sender;

@end
