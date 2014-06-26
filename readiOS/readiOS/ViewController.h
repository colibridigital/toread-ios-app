//
//  ViewController.h
//  readiOS
//
//  Created by Ingrid Funie on 04/01/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookCollectionView.h"
#import "AppDelegate.h"
#import "RetrieveBooks.h"
#import "MBProgressHUD.h"


@interface ViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate,UIAlertViewDelegate, UIActionSheetDelegate,
UIPickerViewDataSource, UIPickerViewDelegate, UISearchBarDelegate, MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
}

- (void)showSimple:(NSString*)urlString;
- (void)showWithCustomView:(NSString*)message;

@property (weak, nonatomic) IBOutlet UIButton *QRreader;

@property (weak, nonatomic) IBOutlet UIButton *customListButton;
- (IBAction)customListSelector:(id)sender;

@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) NSMutableArray *customCollectionImages;
@property (strong, nonatomic) NSMutableArray *tableNames;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSArray *pickerViewData;
@property (nonatomic) BOOL isEditMode;

@property (weak, nonatomic) IBOutlet BookCollectionView *selectedCollectionView;
@property (weak, nonatomic) IBOutlet BookCollectionView *suggestedBooksView;
@property (weak, nonatomic) IBOutlet BookCollectionView *customCollectionView;
@property (weak, nonatomic) IBOutlet BookCollectionView *favouriteCollectionView;
@property (weak, nonatomic) AppDelegate *appDelegate;
@property (retain) RetrieveBooks *retrieveBooks;

@property (strong, nonatomic) NSMutableArray *bookImages;
@property (weak, nonatomic) BookCollectionView *collView;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) NSString* tableName;
@property (strong, nonatomic) NSString* collName;
@property (nonatomic) int uniqueID;
- (IBAction)showQRReader:(id)sender;

- (IBAction)showMenu:(id)sender;
- (void)loadCustomListDatabase:(NSString *)customListButtonTitle;
- (void)loadCustomListDatabaseAndRefreshView:(NSString *)customListButtonTitle;
- (void) initiatePickerViewWithTableNames;

@property(retain) UIAlertView *av;
@property (nonatomic) NSString *customListTitle;

@end
