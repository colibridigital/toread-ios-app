//
//  RegisterViewController.h
//  readiOS
//
//  Created by Ingrid Funie on 06/08/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *lastName;
@property (weak, nonatomic) IBOutlet UITextField *emailAddress;
@property (weak, nonatomic) IBOutlet UISegmentedControl *gender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *occupation;
@property (weak, nonatomic) IBOutlet UISegmentedControl *ageGroup;
- (IBAction)registerUser:(id)sender;
- (IBAction)cancel:(id)sender;

@end
