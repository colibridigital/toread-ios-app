//
//  RegisterViewController.m
//  readiOS
//
//  Created by Ingrid Funie on 06/08/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import "RegisterViewController.h"
#import "TutorialOptionViewController.h"
#import "ViewController.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController

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
    
    self.userExistence.hidden = YES;
    
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

- (IBAction)registerUser:(id)sender {
    
    self.userExistence.hidden = YES;
    
    NSString* sex = @"";
    
    if ([self.gender selectedSegmentIndex] == 0) {
        
        sex = @"Male";
    } else {
        sex = @"Female";
    }
    
    NSString* ageRange = @"";
    
    if ([self.ageGroup selectedSegmentIndex] == 0) {
        ageRange = @"1";
    } else if ([self.ageGroup selectedSegmentIndex] == 1){
        ageRange = @"2";
    } else if ([self.ageGroup selectedSegmentIndex] == 2) {
        ageRange = @"3";
    } else {
        ageRange = @"4";
    }
    
    NSString* occ = @"";
    
    if ([self.occupation selectedSegmentIndex] == 0) {
        occ = @"Employed";
    } else if ([self.occupation selectedSegmentIndex] == 1) {
        occ = @"Student";
    } else if ([self.occupation selectedSegmentIndex] == 2) {
        occ = @"Retired";
    } else {
        occ = @"None";
    }
    
    NSString* responseMessage;
    
    if ([self.appDelegate connectedToInternet]) {
        NSLog(@"Registering");
        responseMessage = [self.appDelegate registerUser:self.username.text password:self.password.text firstName:self.firstName.text lastName:self.lastName.text emailAddress:self.emailAddress.text ageRange:ageRange sex:sex occupation:occ];
    } else {
        
    }
    
    if ([responseMessage isEqualToString:@"Username already exists"]) {
        self.userExistence.hidden = NO;
    } else {
        
        @try {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSeenTutorial"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self.appDelegate doTheDatabaseSetup];
            
            UIStoryboard *mainStoryboard;
            
            mainStoryboard = [self.appDelegate setStoryboard];
            
            
            ViewController *mainViewController = (ViewController*)[mainStoryboard
                                                                   instantiateViewControllerWithIdentifier: @"MainViewController"];
            
            [self.appDelegate setupMenu:mainViewController];
        }
        @catch (NSException *e){
            NSLog(@"Exception thrown %@",e);
        }
    }
    
    
}
- (IBAction)cancel:(id)sender {
    TutorialOptionViewController *tutorial = [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialOptionViewController"];
    
    [self addChildViewController:tutorial];
    [self.view addSubview:tutorial.view];
    [tutorial didMoveToParentViewController:self];
    
}

-(IBAction)textFieldReturn:(id)sender
{
    [sender resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.username isFirstResponder] && [touch view] != self.username) {
        [self.username resignFirstResponder];
    }
    
    if ([self.password isFirstResponder] && [touch view] != self.password) {
        [self.password resignFirstResponder];
    }
    
    if ([self.firstName isFirstResponder] && [touch view] != self.firstName) {
        [self.firstName resignFirstResponder];
    }
    
    if ([self.lastName isFirstResponder] && [touch view] != self.lastName) {
        [self.lastName resignFirstResponder];
    }
    
    if ([self.emailAddress isFirstResponder] && [touch view] != self.emailAddress) {
        [self.emailAddress resignFirstResponder];
    }
    
    [super touchesBegan:touches withEvent:event];
}

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
@end
