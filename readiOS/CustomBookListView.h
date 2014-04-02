//
//  CustomBookListView.h
//  readiOS
//
//  Created by Ingrid Funie on 02/04/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface CustomBookListView : UIViewController


@property (weak, nonatomic) ViewController *viewController;

@property (strong, nonatomic) NSString *listTitle;

@property (weak, nonatomic) IBOutlet UITextField *bookListTitle;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
- (IBAction)cancelButtPressed:(id)sender;
- (IBAction)saveButtPressed:(id)sender;

-(void)setParentViewController:(ViewController*)viewController;

@end
