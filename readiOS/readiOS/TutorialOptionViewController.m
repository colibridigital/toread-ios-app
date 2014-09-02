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
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
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

- (void)showWithCustomView:(NSString*)message {
	
	HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
	
	// The sample image is based on the work by http://www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
	// Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
	HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark@2x.png"]];
	
	// Set custom view mode
	HUD.mode = MBProgressHUDModeCustomView;
	
	HUD.delegate = self;
    //modify this according to the needs
	HUD.labelText = message;
	
	[HUD show:YES];
	[HUD hide:YES afterDelay:1.5];
}

- (IBAction)authenticate:(id)sender {
    
    if ([self.appDelegate connectedToInternet]){
        LoginViewController *loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        
        [self addChildViewController:loginViewController];
        [self.view addSubview:loginViewController.view];
        [loginViewController didMoveToParentViewController:self];
    } else {
        [self showWithCustomView:@"No Internet Connection"];
    }
}

- (IBAction)registerUser:(id)sender {
    
    if ([self.appDelegate connectedToInternet]) {
        RegisterViewController *registerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RegisterViewController"];
        
        [self addChildViewController:registerViewController];
        [self.view addSubview:registerViewController.view];
        [registerViewController didMoveToParentViewController:self];
    } else {
        [self showWithCustomView:@"No Internet Connection"];
    }
}

@end
