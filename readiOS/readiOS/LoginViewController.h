//
//  LoginViewController.h
//  readiOS
//
//  Created by Ingrid Funie on 06/08/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *wrongLoginMessage;
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
- (IBAction)login:(id)sender;

@end
