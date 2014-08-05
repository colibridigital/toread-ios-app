//
//  TutorialViewController.m
//  readiOS
//
//  Created by Ingrid Funie on 31/07/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import "TutorialViewController.h"
#import "ViewController.h"

@interface TutorialViewController ()

@end

@implementation TutorialViewController

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
    
    _pageImages = @[@"tut0.png", @"tut1.png", @"tut2.png", @"tut3.png", @"tut4.png", @"tut5.png", @"tut6.png"];
    _pageDescriptions = @[@"To get started, tap create new list, and select it from the menu:", @"Great.  Now lets find a book to add:", @"To add it to your list, tap the plus icon, and pick your list:", @"Perfect.  To find out more on the book, just tap on its cover:", @"You can even set a reminder to finish reading the book:", @"When you’re done reading the book or want to delete it, press and hold on it:", @"Finally, to see your reading history, tap in the side bar: "];
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialPageViewController"];
    self.pageViewController.dataSource = self;
    
    TutorialPageContentController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 30);
    
   /* UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor whiteColor];*/
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



- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((TutorialPageContentController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((TutorialPageContentController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageDescriptions count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (TutorialPageContentController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageDescriptions count] == 0) || (index >= [self.pageDescriptions count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    TutorialPageContentController *pageContentController = [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialPageContentController"];
    pageContentController.imageFile = self.pageImages[index];
    pageContentController.descriptionText = self.pageDescriptions[index];
    pageContentController.pageIndex = index;
    
    return pageContentController;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageDescriptions count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

- (IBAction)showTutorial:(id)sender {
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}
- (IBAction)skipTutorial:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSeenTutorial"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.appDelegate doTheDatabaseSetup];
    
    UIStoryboard *mainStoryboard = [self.appDelegate setStoryboard];
    
    ViewController *mainViewController = (ViewController*)[mainStoryboard
                                                           instantiateViewControllerWithIdentifier: @"MainViewController"];
    
    //self.appDelegate.window.rootViewController = mainViewController;
    //[self.appDelegate.window makeKeyAndVisible];
    
    [self.appDelegate setupMenu:mainViewController];
}
@end
