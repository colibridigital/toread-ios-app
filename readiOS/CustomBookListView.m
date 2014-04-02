//
//  CustomBookListView.m
//  readiOS
//
//  Created by Ingrid Funie on 02/04/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import "CustomBookListView.h"
#import "ViewController.h"


@interface CustomBookListView ()

@end

@implementation CustomBookListView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"initialize");
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"show view");
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveButtPressed:(id)sender {
    NSLog(@"here %@", self.bookListTitle.text);
    self.listTitle = self.bookListTitle.text;
    [self.viewController.customListButton setTitle:self.listTitle forState:UIControlStateNormal];
    
    NSArray *newBookList = [[NSMutableArray alloc] init];
    self.viewController.customCollectionImages = newBookList;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setParentViewController:(ViewController *)viewController {
    self.viewController = viewController;
}

@end
