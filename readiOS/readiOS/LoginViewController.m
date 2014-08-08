//
//  LoginViewController.m
//  readiOS
//
//  Created by Ingrid Funie on 06/08/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import "LoginViewController.h"
#import "TutorialViewController.h"
#import "ViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

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
    self.wrongLoginMessage.hidden = YES;
    
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

- (IBAction)login:(id)sender {
    
    NSString* responseMessage;
    
    self.wrongLoginMessage.hidden = YES;
    
    if ([self.appDelegate connectedToInternet]) {
        NSLog(@"loging in");
        responseMessage = [self.appDelegate login:self.username.text password:self.password.text];
    }
    
    if ([responseMessage isEqualToString:@"Invalid username or password"]) {
        NSLog(@"can t login");
        self.wrongLoginMessage.hidden = NO;
    } else {
    
        [self.appDelegate requestBooksAndCreateDatabaseEntries];
    
        UIStoryboard *mainStoryboard;
    
        mainStoryboard = [self.appDelegate setStoryboard];
    
    
        ViewController *mainViewController = (ViewController*)[mainStoryboard
                                                           instantiateViewControllerWithIdentifier: @"MainViewController"];
    
        [self.appDelegate setupMenu:mainViewController];
    }

    
}

- (IBAction)cancel:(id)sender {
    TutorialViewController *tutorial = [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialViewController"];
    
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
    
    [super touchesBegan:touches withEvent:event];
}
@end
