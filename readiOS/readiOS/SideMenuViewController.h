//
//  SideMenuViewController.h
//  MFSideMenuDemo
//
//  Created by Michael Frederick on 3/19/12.

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "EmailManager.h"

@interface SideMenuViewController : UITableViewController<MFMailComposeViewControllerDelegate,
UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) NSMutableArray *tableNames;
@property (strong, nonatomic) NSArray *pickerViewData;
@property (strong, nonatomic) NSString* listTitle;
@property (strong, nonatomic) UINavigationController *navigationController;

@property (weak, nonatomic) AppDelegate *appDelegate;
@property (nonatomic, retain) EmailManager *emailManager;

- (void) initiatePickerViewWithTableNames;

@property(retain) UIAlertView *av;
@end