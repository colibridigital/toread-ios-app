//
//  TutorialOptionViewController.m
//  readiOS
//
//  Created by Ingrid Funie on 28/08/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import "TutorialOptionViewController.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"

@interface TutorialOptionViewController ()

@end

@implementation TutorialOptionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //show short video with "Welcome toRead" message and some flowing books
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)authenticate:(id)sender {
    LoginViewController *loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    
    [self addChildViewController:loginViewController];
    [self.view addSubview:loginViewController.view];
    [loginViewController didMoveToParentViewController:self];
}

- (IBAction)registerUser:(id)sender {
    RegisterViewController *registerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RegisterViewController"];
    
    [self addChildViewController:registerViewController];
    [self.view addSubview:registerViewController.view];
    [registerViewController didMoveToParentViewController:self];
}

@end
