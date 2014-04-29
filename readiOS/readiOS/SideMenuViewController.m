//
//  SideMenuViewController.m
//  MFSideMenuDemo
//
//  Created by Michael Frederick on 3/19/12.

#import "SideMenuViewController.h"
#import "MFSideMenu.h"
#import "ViewController.h"
#import "CustomBookListView.h"

@implementation SideMenuViewController

#pragma mark -
#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString * title = [NSString stringWithFormat:@"Section %ld", (long)section];
    
    return title;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    NSIndexPath *firstRowPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    if ([indexPath isEqual:firstRowPath]) {
        cell.textLabel.text = [NSString stringWithFormat:@"What I've Read"];
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"Item %ld", (long)indexPath.row];
    }
    cell.backgroundColor = [UIColor blackColor];
    cell.textLabel.textColor = [UIColor grayColor];
    
    return cell;
}

#pragma mark -
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if ([indexPath  isEqual:[NSIndexPath indexPathForRow:0 inSection:0]]) {
        NSLog(@"in read books selection");
        CustomBookListView *bookListView = [[CustomBookListView alloc] initWithNibName:@"CustomBookListView" bundle:nil];
        NSLog(@"initialized view");
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSArray *controllers = [NSArray arrayWithObject:bookListView];
        navigationController.viewControllers = controllers;
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];

    } else {
    
    ViewController *demoController = [[ViewController alloc] init];
    demoController.title = [NSString stringWithFormat:@"Demo #%ld-%ld", (long)indexPath.section, (long)indexPath.row];
    
    
    
    UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
    NSArray *controllers = [NSArray arrayWithObject:demoController];
    navigationController.viewControllers = controllers;
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    }
}

@end
